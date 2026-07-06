import cds from '@sap/cds';

export default class ISUService extends cds.ApplicationService {
    async init() {
        await super.init();

        const { Outages, MeterReadings, Meters } = this.entities;

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

        this.before(['CREATE', 'UPDATE'], Outages, (req) => {
            const { outageStartDate, outageEndDate } = req.data;
            if (outageEndDate && outageStartDate && outageEndDate <= outageStartDate) {
                req.error(400, 'End date must be after start date');
            }
        });
    }
}
