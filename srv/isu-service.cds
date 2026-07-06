using { sap.isu as isu } from '../db/schema';

service ISUService {
    @readonly
    entity Customers as projection on isu.Customers;
    entity Premises as projection on isu.Premises;
    entity Meters as projection on isu.Meters actions {
        action registerReading(value : Integer, date : Date);
    };
    entity MeterReadings as projection on isu.MeterReadings;
    entity Outages as projection on isu.Outages actions {
        action confirm();
    };
}
