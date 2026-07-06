import cds from '@sap/cds';

export default class ISUService extends cds.ApplicationService {
    async init() {
        await super.init();

        const { Customers, Premises, Outages, MeterReadings, Meters } = this.entities;

        this.on('confirm', Outages, async (req) => {
            const keys = req.params.at(-1) as { outageID?: string } | string;
            const outageID = typeof keys === 'object' ? keys.outageID : keys;
            if (!outageID) return req.error(400, 'Outage ID is required');

            const selectedOutage = await SELECT.one.from(Outages).where({ outageID });

            if (!selectedOutage) return req.error(404, 'Outage not found');
            if (selectedOutage.outageStatus !== 'REPORTED') {
                return req.error(400, 'Only REPORTED outages can be confirmed');
            }

            await UPDATE(Outages).set({ outageStatus: 'CONFIRMED' }).where({ outageID });
            return await SELECT.one.from(Outages).where({ outageID });
        });

        this.on('registerReading', Meters, async (req) => {
            const keys = req.params.at(-1) as { meterID?: string } | string;
            const meterID = typeof keys === 'object' ? keys.meterID : keys;
            const { value, date: readingDate } = req.data;
            if (!meterID) return req.error(400, 'Meter ID is required');

            const selectedMeter = await SELECT.one.from(Meters).where({ meterID });
            if (!selectedMeter) return req.error(404, 'Meter not found');

            await INSERT.into(MeterReadings).entries({
                readingID: crypto.randomUUID(),
                readingValue: value,
                readingDate: readingDate,
                readingType: 'Actual',
                meter_meterID: meterID,
            });
        });

        this.on('explainBill', Customers, async (req) => {
            const keys = req.params.at(-1) as { customerID?: string } | string;
            const customerID = typeof keys === 'object' ? keys.customerID : keys;

            const customer = await SELECT.one.from(Customers).where({ customerID });
            if (!customer) return req.error(404, 'Customer not found');

            let info = 'Customer: ' + customer.customerName + '\n';

            const premises = await SELECT.from(Premises).where({ customer_customerID: customerID });
            for (const premise of premises) {
                info += 'Address: ' + premise.premisesStreet + ', ' + premise.premisesCity + '\n';

                const meters = await SELECT.from(Meters).where({ premise_premisesID: premise.premisesID });
                for (const meter of meters) {
                    const readings = await SELECT.from(MeterReadings)
                        .where({ meter_meterID: meter.meterID })
                        .orderBy('readingDate');

                    info += meter.meterType + ' meter ' + meter.meterSerialNumber;
                    info += ' (' + meter.meterUnit + '):\n';

                    for (const reading of readings) {
                        info += '  ' + reading.readingDate + ' = ' + reading.readingValue;
                        info += ' (' + reading.readingType + ')\n';
                    }
                }
            }

            const prompt =
                'You work for an energy supplier. Explain this customer\'s bill in plain language.\n' +
                'The numbers are meter register readings (cumulative), not euro amounts.\n' +
                'For each meter, compare the last two readings to estimate recent consumption.\n' +
                'Say if usage went up or down compared to the period before that, when possible.\n' +
                'Use kWh for electricity and m3 for gas. Do not invent prices or contract details.\n' +
                'Write 2-3 short paragraphs the customer can understand.\n' +
                'Do not add greetings, sign-offs, or lines like "feel free to reach out" or "contact us".\n\n' +
                info;

            const response = await fetch('https://api.openai.com/v1/chat/completions', {
                method: 'POST',
                headers: {
                    Authorization: 'Bearer ' + process.env.OPENAI_API_KEY,
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    model: 'gpt-4o-mini',
                    messages: [{ role: 'user', content: prompt }],
                }),
            });

            const data = await response.json();

            if (!response.ok) {
                const msg = data.error?.message ?? 'OpenAI request failed';
                return req.error(502, msg);
            }

            const explanation = data.choices?.[0]?.message?.content;
            if (!explanation) return req.error(502, 'OpenAI returned no explanation');

            req.info(explanation);
            return explanation;
        });

        this.before(['CREATE', 'UPDATE'], Outages, (req) => {
            const { outageStartDate, outageEndDate } = req.data;
            if (outageEndDate && outageStartDate && outageEndDate <= outageStartDate) {
                req.error(400, 'End date must be after start date');
            }
        });
    }
}
