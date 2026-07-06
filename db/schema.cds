namespace sap.isu;

type EnergyType : String enum { Electricity; Gas; Water; Heat };
type OutageStatus : String enum { REPORTED; CONFIRMED; RESOLVED };
type ReadingType : String enum { Actual; Estimated };
type OutageSeverity : String enum { LOW; MEDIUM; HIGH };

entity Customers {
  key customerID : UUID;
  customerName : String;
  customerAddress : String;
  customerCity : String;
  customerState : String;
  customerZip : String;
  customerCountry : String;

  premises : Composition of many Premises on premises.customer = $self;
}

entity Premises {
  key premisesID : UUID;
  premisesStreet : String;
  premisesCity : String;
  premisesZip : String;

  customer : Association to Customers;
  meters : Composition of many Meters on meters.premise = $self;
  outages : Composition of many Outages on outages.premise = $self;
}

entity Meters {
  key meterID : UUID;
  meterType : EnergyType;
  meterSerialNumber : String;
  meterInstallationDate : Date;
  meterLocation : String;
  meterUnit : String = case meterType
    when 'Electricity' then 'kWh'
    when 'Gas'        then 'm3'
    when 'Water'      then 'm3'
    when 'Heat'       then 'kWh'
  end;

  readings : Composition of many MeterReadings on readings.meter = $self;
  premise : Association to Premises;
}

entity MeterReadings {
  key readingID : UUID;
  readingDate : Date;
  readingValue : Integer;
  readingType : ReadingType;

  meter : Association to Meters;
}

entity Outages {
  key outageID : UUID;
  outageStartDate : Date;
  outageEndDate : Date;
  outageStatus : OutageStatus;
  outageDescription : String;
  outageSeverity : OutageSeverity;

  premise : Association to Premises;
}
