# Shelter from the Storm — Salesforce Nonprofit Cloud build

Production case management system for Shelter from the Storm Inc., a domestic
violence shelter in Indiana. Built on Salesforce Nonprofit Cloud with the
Case Management managed package, Enterprise Edition.

## What this project covers

- Hotline + intake workflow (priority)
- Resident case management (bed board, case notes, services)
- Children's program tracking
- VOCA / VAWA / FVPSA grant reporting
- Indiana ICJI-compliant data structure

## Tech stack

- Salesforce Nonprofit Cloud Enterprise Edition (org `sfts-prod-DANGER`)
- Nonprofit Cloud Case Management managed package (activated March 2026)
- Salesforce CLI (`sf`) — source format SFDX project
- API version 66.0
- Git for version control
- Node.js + npm for any tooling

## Org aliases

| Alias               | Purpose                                                   |
| ------------------- | --------------------------------------------------------- |
| `sfts-prod-DANGER`  | Production. **Never deploy here without explicit go-ahead.** |
| `sfts-dev`          | Developer Sandbox. **Default target for all work.**       |

When running any `sf` command, always pass `--target-org sfts-dev` explicitly
unless you have a specific, confirmed reason to target production.

## Critical safety rules

### 1. No real client data, ever, anywhere in this project
- All test records use synthetic names ("Jane Test," "Sample Survivor," etc.)
- Real survivor data must never enter the project folder, the git history,
  code comments, screenshots, or this README
- The `.gitignore` blocks folders named `private/`, `real-data/`,
  `client-data/`, `production-export/`, `survivor-data/`, etc. — if a file
  needs one of those names to describe it, it does not belong in the repo

### 2. Sandbox-first, always
- All metadata changes are built and verified in `sfts-dev` first
- Production deployments require explicit human approval
- A change is "done" only after it has been validated in sandbox

### 3. VAWA confidentiality posture
- Contact (Client) record OWD is **Private**
- PII fields use field-level security restricted by role
- Indiana ACP flag on Contact suppresses address display when set
- Sensitive field history tracking enabled
- Audit trail on all PII fields

### 4. Mandatory reporting
- APS (Adult Protective Services — endangered adults)
- DCS (Department of Child Services — child abuse)
- Tracking objects must not be edited or deleted after creation

## Repository layout

```
SalesForce/
├── sfdx-project.json          # SFDX project manifest (API 66.0)
├── .gitignore                 # Comprehensive safety-tuned ignores
├── .forceignore               # Excludes from sf retrieve/deploy
├── README.md                  # This file
├── force-app/
│   └── main/
│       └── default/           # All metadata source lives here
├── manifest/
│   └── package.xml            # Deployment manifest
├── config/
│   └── project-scratch-def.json
├── docs/
│   ├── 00-decisions.md        # Architecture Decision Record log
│   └── 01-org-discovery.md    # Findings from initial org audit
└── scripts/                   # Helper scripts (not deployed)
```

## Common commands

| Task                            | Command                                                                          |
| ------------------------------- | -------------------------------------------------------------------------------- |
| Check authenticated orgs        | `sf org list`                                                                    |
| Retrieve metadata from sandbox  | `sf project retrieve start --metadata <Type:Name> --target-org sfts-dev`         |
| Deploy to sandbox               | `sf project deploy start --source-dir force-app --target-org sfts-dev`           |
| Run SOQL query                  | `sf data query --query "SELECT Id FROM Contact LIMIT 5" --target-org sfts-dev`   |
| Open the org in browser         | `sf org open --target-org sfts-dev`                                              |

## Build status / day-by-day

See `docs/00-decisions.md` for architectural decisions and progress notes.

## Architectural philosophy

Smart hybrid:

- **80%** Salesforce configuration (objects, fields, layouts, permissions,
  validation rules)
- **15%** Flow Builder (screen flows, record-triggered, scheduled)
- **5%**  Apex / LWC, only where Flow genuinely cannot do the job

The admin executing this build is non-developer. Maintenance burden of Apex
on a non-developer team is real and considered in every design decision.
