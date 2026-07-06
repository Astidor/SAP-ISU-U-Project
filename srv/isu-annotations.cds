using ISUService from './isu-service';
using { sap } from '@sap/cds/common';

// --- Action side effects (UI refresh after POST) ---

annotate ISUService.Outages actions {
    confirm @(Common: {
        SideEffects: {
            TargetProperties: ['outageStatus'],
            TargetEntities: ['/ISUService.EntityContainer/Outages']
        }
    });
};

annotate ISUService.Meters actions {
    registerReading @(Common: {
        SideEffects: {
            TargetEntities: ['/ISUService.EntityContainer/MeterReadings']
        }
    });
};

// --- Customers ---

annotate ISUService.Customers with @(UI: {
    HeaderInfo: {
        TypeName      : 'Customer',
        TypeNamePlural: 'Customers',
        Title         : { Value: customerName },
        Description   : { Value: customerCity }
    },
    SelectionFields: [
        customerName,
        customerCity,
        customerCountry
    ],
    LineItem: [
        { Value: customerName, Label: 'Name' },
        { Value: customerCity, Label: 'City' },
        { Value: customerState, Label: 'Region' },
        { Value: customerCountry, Label: 'Country' }
    ],
    Facets: [{
        $Type : 'UI.ReferenceFacet',
        ID    : 'Premises',
        Label : 'Premises',
        Target: 'premises/@UI.LineItem'
    }]
});

// --- Premises ---

annotate ISUService.Premises with @(UI: {
    HeaderInfo: {
        TypeName      : 'Premise',
        TypeNamePlural: 'Premises',
        Title         : { Value: premisesStreet },
        Description   : { Value: premisesCity }
    },
    SelectionFields: [
        premisesStreet,
        premisesCity,
        premisesZip
    ],
    LineItem: [
        { Value: premisesStreet, Label: 'Street' },
        { Value: premisesCity, Label: 'City' },
        { Value: premisesZip, Label: 'Postal code' },
        { Value: customer.customerName, Label: 'Customer' }
    ],
    Facets: [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'Meters',
            Label : 'Meters',
            Target: 'meters/@UI.LineItem'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'Outages',
            Label : 'Outages',
            Target: 'outages/@UI.LineItem'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'Customer',
            Label : 'Customer',
            Target: '@UI.FieldGroup#Customer'
        }
    ],
    FieldGroup #Customer: {
        Data: [
            { Value: customer.customerName, Label: 'Name' },
            { Value: customer.customerCity, Label: 'City' },
            { Value: customer.customerCountry, Label: 'Country' }
        ]
    }
});

// --- Meters ---

annotate ISUService.Meters with @(UI: {
    HeaderInfo: {
        TypeName      : 'Meter',
        TypeNamePlural: 'Meters',
        Title         : { Value: meterSerialNumber },
        Description   : { Value: meterType }
    },
    SelectionFields: [
        meterSerialNumber,
        meterType,
        premise.premisesCity
    ],
    LineItem: [
        { Value: meterSerialNumber, Label: 'Serial' },
        { Value: meterType, Label: 'Type' },
        { Value: meterUnit, Label: 'Unit' },
        { Value: premise.premisesCity, Label: 'City' },
        {
            $Type : 'UI.DataFieldForAction',
            Label : 'Register reading',
            Action: 'ISUService.registerReading',
            Inline: true
        }
    ],
    Facets: [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'Readings',
            Label : 'Meter readings',
            Target: 'readings/@UI.LineItem'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'Premise',
            Label : 'Premise',
            Target: '@UI.FieldGroup#Premise'
        }
    ],
    FieldGroup #Premise: {
        Data: [
            { Value: premise.premisesStreet, Label: 'Street' },
            { Value: premise.premisesCity, Label: 'City' },
            { Value: premise.premisesZip, Label: 'Postal code' }
        ]
    }
});

// --- Meter readings ---

annotate ISUService.MeterReadings with @(UI: {
    HeaderInfo: {
        TypeName      : 'Meter reading',
        TypeNamePlural: 'Meter readings',
        Title         : { Value: readingID },
        Description   : { Value: readingDate }
    },
    SelectionFields: [
        readingDate,
        readingType
    ],
    LineItem: [
        { Value: readingDate, Label: 'Date' },
        { Value: readingValue, Label: 'Value' },
        { Value: readingType, Label: 'Type' },
        { Value: meter.meterSerialNumber, Label: 'Meter' }
    ],
    Facets: [{
        $Type : 'UI.ReferenceFacet',
        ID    : 'Meter',
        Label : 'Meter',
        Target: '@UI.FieldGroup#Meter'
    }],
    FieldGroup #Meter: {
        Data: [
            { Value: meter.meterSerialNumber, Label: 'Serial' },
            { Value: meter.meterType, Label: 'Type' },
            { Value: meter.meterUnit, Label: 'Unit' }
        ]
    }
});

// --- Outages ---

annotate ISUService.Outages with @(UI: {
    HeaderInfo: {
        TypeName      : 'Outage',
        TypeNamePlural: 'Outages',
        Title         : { Value: outageID },
        Description   : { Value: outageStatus }
    },
    SelectionFields: [
        outageStatus,
        outageSeverity,
        outageStartDate
    ],
    LineItem: [
        { Value: outageStatus, Label: 'Status' },
        { Value: outageStartDate, Label: 'Start' },
        { Value: outageSeverity, Label: 'Severity' },
        { Value: premise.premisesCity, Label: 'Premise city' },
        {
            $Type : 'UI.DataFieldForAction',
            Label : 'Confirm outage',
            Action: 'ISUService.confirm',
            Inline: true
        }
    ],
    Facets: [{
        $Type : 'UI.ReferenceFacet',
        ID    : 'Premise',
        Label : 'Premise',
        Target: '@UI.FieldGroup#Premise'
    }],
    FieldGroup #Premise: {
        Data: [
            { Value: premise.premisesStreet, Label: 'Street' },
            { Value: premise.premisesCity, Label: 'City' },
            { Value: premise.premisesZip, Label: 'Postal code' }
        ]
    }
});
