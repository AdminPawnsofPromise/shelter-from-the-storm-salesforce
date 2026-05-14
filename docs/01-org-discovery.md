# Org discovery — Shelter from the Storm production org

Findings from the initial audit of the production org. Updated as discovery
proceeds.

## Confirmed (Day 1)

| Property                | Value                                              |
| ----------------------- | -------------------------------------------------- |
| Org name                | Shelter From the Storm Inc                         |
| Org ID                  | `00Dam00001bxg8fEAA`                               |
| Edition                 | Enterprise Edition                                 |
| Instance                | USA788 (US production pod)                         |
| API version             | 66.0                                               |
| Is sandbox?             | No (real production)                               |
| Authenticating user     | admin@sftsinc.com                                  |
| CLI alias               | `sfts-prod-DANGER` (default for now; will flip to `sfts-dev` post-sandbox) |
| My Domain               | shelterfromthestorminc.my.salesforce.com           |

## Pending discovery (Step 3)

- [ ] Installed managed packages — confirm Nonprofit Cloud Case Management
      version (NPSP-based vs new Nonprofit Cloud architecture)
- [ ] Available standard objects — Program, ProgramEnrollment,
      ProgramProductAssignment, BenefitAssignment, etc. (NPC) vs. NPSP
      objects (npsp__Program__c, npe5__Affiliation__c, etc.)
- [ ] License consumption — Power of Us licenses assigned (10 available)
- [ ] Active users and roles
- [ ] Existing custom objects (if any)
- [ ] Existing flows, permission sets, profiles
- [ ] Health Check score and any obvious security gaps
