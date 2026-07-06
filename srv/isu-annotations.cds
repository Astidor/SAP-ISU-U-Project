using ISUService from './isu-service';
using { sap } from '@sap/cds/common';

// --- Action side effects (UI refresh after POST) ---

annotate ISUService.Customers actions {
    explainBill @(Common: {
        SideEffects: {
            TargetProperties: []
        }
    });
};

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
        customerState,
        customerCountry
    ],
    LineItem: [
        {
            $Type : 'UI.DataFieldForAction',
            Label : 'Explain bill',
            Action: 'ISUService.explainBill',
            Inline: true
        },
        { Value: customerName, Label: 'Name' },
        { Value: customerAddress, Label: 'Address' },
        { Value: customerCity, Label: 'City' },
        { Value: customerState, Label: 'Region' },
        { Value: customerZip, Label: 'Postal code' },
        { Value: customerCountry, Label: 'Country' }
    ],
    Identification: [{
        $Type : 'UI.DataFieldForAction',
        Label : 'Explain bill',
        Action: 'ISUService.explainBill'
    }],
    SelectionPresentationVariant #Default: {
        PresentationVariant: {
            Visualizations: ['@UI.LineItem']
        }
    },
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
    SelectionPresentationVariant #Default: {
        PresentationVariant: {
            Visualizations: ['@UI.LineItem']
        }
    },
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
        {
            $Type : 'UI.DataFieldForAction',
            Label : 'Register reading',
            Action: 'ISUService.registerReading',
            Inline: true
        },
        { Value: meterSerialNumber, Label: 'Serial' },
        { Value: meterType, Label: 'Type' },
        { Value: meterUnit, Label: 'Unit' },
        { Value: meterLocation, Label: 'Location' },
        { Value: meterInstallationDate, Label: 'Installed' },
        { Value: premise.premisesCity, Label: 'City' }
    ],
    Identification: [{
        $Type : 'UI.DataFieldForAction',
        Label : 'Register reading',
        Action: 'ISUService.registerReading'
    }],
    SelectionPresentationVariant #Default: {
        PresentationVariant: {
            Visualizations: ['@UI.LineItem']
        }
    },
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
        { Value: meter.meterSerialNumber, Label: 'Meter' },
        { Value: meter.meterType, Label: 'Meter type' }
    ],
    SelectionPresentationVariant #Default: {
        PresentationVariant: {
            Visualizations: ['@UI.LineItem']
        }
    },
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
        Title         : { Value: outageDescription },
        Description   : { Value: outageStatus }
    },
    SelectionFields: [
        outageStatus,
        outageSeverity,
        outageStartDate
    ],
    LineItem: [
        {
            $Type : 'UI.DataFieldForAction',
            Label : 'Confirm outage',
            Action: 'ISUService.confirm',
            Inline: true
        },
        { Value: outageStatus, Label: 'Status' },
        { Value: outageStartDate, Label: 'Start' },
        { Value: outageEndDate, Label: 'End' },
        { Value: outageSeverity, Label: 'Severity' },
        { Value: outageDescription, Label: 'Description' },
        { Value: premise.premisesCity, Label: 'Premise city' }
    ],
    Identification: [{
        $Type : 'UI.DataFieldForAction',
        Label : 'Confirm outage',
        Action: 'ISUService.confirm'
    }],
    SelectionPresentationVariant #Default: {
        PresentationVariant: {
            Visualizations: ['@UI.LineItem']
        }
    },
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
