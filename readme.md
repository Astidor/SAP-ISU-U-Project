# SAP ISU-U Project

A small SAP BTP CAP app for learning utilities domain modeling. It covers customers, premises, meters, meter readings, and outages. The names and relationships borrow from SAP IS-U, but this is not IS-U. It is a side application you could imagine next to a real utilities system of record.

I built it to practice CDS, OData V4, TypeScript handlers, seed data, Fiori annotations, and the deployment files you need before Cloud Foundry. Local dev uses SQLite. Production bindings (HANA, XSUAA) are prepared in `mta.yaml` and `xs-security.json`.
## Demo
https://github.com/user-attachments/assets/00237df4-ece9-4f3f-9a63-3b745245aed3






## Domain model

| Entity | What it represents |
|--------|--------------------|
| Customers | Account holders |
| Premises | Supply addresses |
| Meters | Electricity or gas devices |
| MeterReadings | Register values |
| Outages | Supply interruptions |

A customer has premises. A premise has meters and outages. A meter has readings.

Namespace: `sap.isu`. Service: `ISUService` at `/odata/v4/isu/`.

## Stack

- Node.js 22, SAP CAP 10, TypeScript
- `@cap-js/sqlite` locally, `@cap-js/hana` for BTP
- Fiori Elements preview (built into CAP via `@sap/cds-fiori`)

## Run locally

```powershell
npm install
cds watch
```

Open http://localhost:4004/ for the CAP service index.

Useful URLs:

- OData service root: http://localhost:4004/odata/v4/isu/
- Metadata: http://localhost:4004/odata/v4/isu/$metadata
- Fiori preview (customers): http://localhost:4004/$fiori-preview/ISUService/Customers
- Fiori preview (meters): http://localhost:4004/$fiori-preview/ISUService/Meters
- Fiori preview (outages): http://localhost:4004/$fiori-preview/ISUService/Outages

On the meters list, select a row and open the object page to see readings. The **Register reading** action opens a dialog for value and date. On outages, **Confirm** moves a REPORTED outage to CONFIRMED. On customers, **Explain bill** shows the AI answer in a message.

## Handlers

`srv/isu-service.ts` implements three bound actions:

- `confirm` on Outages (only when status is REPORTED)
- `registerReading` on Meters (inserts a new reading)
- `explainBill` on Customers (OpenAI bill explanation, shown via `req.info` )

Needs `OPENAI_API_KEY` in `.env`.

Fiori refresh after actions uses `@Common.SideEffects` in `srv/isu-annotations.cds`.

## Project layout

```
db/schema.cds              Domain entities and enums
db/data/sap.isu-*.csv      Seed data (Random addresses)
srv/isu-service.cds        OData service
srv/isu-service.ts         TypeScript handlers
srv/isu-annotations.cds    Fiori UI annotations
mta.yaml                   MTA for Cloud Foundry
xs-security.json           XSUAA roles and scopes
```

## BTP deploy (optional)

You need a BTP subaccount, Cloud Foundry space, and the CF/MBT tools. Typical flow:

```powershell
mbt build
cf deploy mta_archives/<generated>.mtar
```

I have not deployed this build from the repo yet. `cds watch` is the path that is actually tested.


## License

Private learning project.
