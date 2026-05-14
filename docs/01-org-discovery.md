# Org discovery — Shelter from the Storm production org

Findings from the Day 1 audit of the production org (`sfts-prod-DANGER`).

## Org facts

| Property                | Value                                              |
| ----------------------- | -------------------------------------------------- |
| Org name                | Shelter From the Storm Inc                         |
| Org ID                  | `00Dam00001bxg8fEAA`                               |
| Edition                 | Enterprise Edition                                 |
| Instance                | USA788 (US production pod)                         |
| API version             | 66.0                                               |
| Is sandbox?             | No (real production)                               |
| My Domain               | shelterfromthestorminc.my.salesforce.com           |
| Locale                  | en_US                                              |
| Language                | en_US                                              |
| Fiscal year start       | January (calendar year)                            |
| **Timezone**            | **America/Los_Angeles** ⚠️ wrong — needs America/Indiana/Indianapolis |

## Installed managed packages

| Name                       | Namespace    | Version          | Notes                                          |
| -------------------------- | ------------ | ---------------- | ---------------------------------------------- |
| Case Management            | `caseman`    | 1.38.0 (build 3) | Legacy NPSP-era Case Management for Nonprofits |
| Program Management Module  | `pmdm`       | 1.34.0 (build 4) | Legacy PMM — Programs, Services, Engagements   |
| OmniStudio                 | `omnistudio` | 260.10.1.1 (Spring 2026) | Modern guided-flow engine (FlexCards, OmniScripts, DataRaptors) |
| SFDO Base                  | `sfdobase`   | 1.0.0 (build 5)  | Shared foundation for Salesforce.org packages  |
| Sales Insights             | `OIQ`        | 1.0.0 (build 1)  | Not relevant to our use case                   |

InstalledPackage metadata retrieved to `force-app/main/default/installedPackages/`.

## Architecture diagnosis

**This org runs the LEGACY NPSP-era stack, not the new Nonprofit Cloud architecture.**

| Object family          | Modern NPC (CareProgram, BenefitAssignment) | Legacy stack (caseman, pmdm) |
| ---------------------- | ------------------------------------------- | ---------------------------- |
| Installed in this org? | **No** — objects not present                | **Yes** — both packages present and active |
| PSL licensed?          | Yes (Care Plans, Benefit Mgmt, etc.)        | Yes                          |

The modern Nonprofit Cloud PSLs (Care Plans, Program and Benefit Management, etc.) are licensed and active, but the underlying objects (CareProgram, CareProgramEnrollee, BenefitAssignment, etc.) are **not present** in this org. Enabling them would require additional setup actions in Salesforce Setup (Nonprofit Cloud features → enable) and possibly installing additional packages.

**Decision (ADR-004 — see 00-decisions.md):** stay on the installed legacy stack for the 2-week build. Rationale: it's what's installed, it has all the objects we need for DV shelter case management, and pivoting architectures mid-build would consume 1-2 days that the timeline cannot absorb.

## Available data model — what we'll build on

### From `caseman` (Case Management for Nonprofits)

| API name                       | Label                  | Purpose for DV shelter                |
| ------------------------------ | ---------------------- | ------------------------------------- |
| `caseman__Intake__c`           | Intake                 | Initial intake records (1 row exists) |
| `caseman__Assessment__c`       | Assessment             | Holds Danger Assessment scores        |
| `caseman__AssessmentThreshold__mdt` | Assessment Threshold (CMDT) | Tiered scoring boundaries        |
| `caseman__CasePlan__c`         | Case Plan              | Per-survivor goals & action plan      |
| `caseman__Goal__c`             | Goal                   | Specific goals within a case plan     |
| `caseman__GoalTemplate__c`     | Goal Template          | Reusable goal definitions             |
| `caseman__ActionItem__c`       | Action Item            | Tasks toward a goal                   |
| `caseman__ActionItemTemplate__c` | Action Item Template | Reusable action items                 |
| `caseman__ActionPlanTemplateGroup__c` | Action Plan Template Group | Pre-canned action plans       |
| `caseman__ClientAlert__c`      | Client Alert           | **Critical for DV: safety flags, "do not release information" warnings** |
| `caseman__ClientNote__c`       | Client Note            | Case notes                            |
| `caseman__ClientNoteRelationship__c` | Client Note Relationship | Link notes across contacts      |
| `caseman__ClientSettings__c`   | Client Settings        | Per-org configuration                 |

### From `pmdm` (Program Management Module)

| API name                       | Label                  | Purpose for DV shelter                |
| ------------------------------ | ---------------------- | ------------------------------------- |
| `pmdm__Program__c`             | Program                | "Emergency Shelter," "Hotline," "Court Advocacy," "Children's Program" |
| `pmdm__ProgramCohort__c`       | Program Cohort         | Groups (e.g., children's group sessions) |
| `pmdm__ProgramEngagement__c`   | Program Engagement     | A survivor enrolled in a program      |
| `pmdm__Service__c`             | Service                | Definable services (counseling session, advocacy hour, etc.) |
| `pmdm__ServiceDelivery__c`     | Service Delivery       | **Per-VOCA reporting: a delivered service unit** |
| `pmdm__ServiceParticipant__c`  | Service Participant    | Link participant to scheduled service |
| `pmdm__ServiceSchedule__c`     | Service Schedule       | Recurring service schedule            |
| `pmdm__ServiceSession__c`      | Service Session        | A specific session of a scheduled service |

### Custom objects we will build (Day 2-3)

These do NOT exist in the org yet — zero custom objects in the no-namespace zone.

| API name (planned)    | Purpose                                       | Why custom (not a stock object)                |
| --------------------- | --------------------------------------------- | ---------------------------------------------- |
| `Hotline_Call__c`     | Each call to the 24/7 hotline                 | Hotline ≠ Intake; needs distinct fast-capture UX |
| `Danger_Assessment__c` | Lethality risk scoring (Campbell DA / DA-IT) | Domain-specific scoring; reuses Assessment? — open question |
| `Mandatory_Report__c` | APS / DCS mandatory-reporting events          | Indiana-required tracking, no stock equivalent |
| `Bed_Assignment__c`   | Who is in which bed, when                     | Shelter operations, no stock equivalent        |

## Users and license consumption

### Active users (8 total — 3 humans, 5 system)

| Username                                    | Profile                          | Last login   | Type             |
| ------------------------------------------- | -------------------------------- | ------------ | ---------------- |
| `admin@sftsinc.com`                         | System Administrator             | Today        | Standard         |
| `director@sftsinc.com`                      | Program Management Standard User | Yesterday    | Standard         |
| `clientadvocate@sftsinc.com`                | Program Management Standard User | 2026-03-10 (2 months ago) | Standard |
| chatty (Chatter bot)                        | Chatter Free User                | never        | CsnOnly          |
| cloud@…                                     | —                                | never        | CloudIntegrationUser |
| insightsintegration@…                       | Sales Insights Integration User  | never        | Standard         |
| automatedclean@…                            | —                                | never        | AutomatedProcess |
| autoproc@…                                  | —                                | never        | AutomatedProcess |

### User licenses

- **Salesforce (full)**: 11 total / 3 used. 8 free.
- The brief mentioned "10 Power of Us licenses"; the org shows 11 — likely a small discrepancy with the donated grant count.

### Permission Set Licenses worth noting

- **Nonprofit Cloud Case Management** (the $360/yr Service Cloud EE RUL): 1 total / 1 used — **assigned to `clientadvocate@sftsinc.com`**.
- Modern Nonprofit Cloud PSLs (Care Plans, Program and Benefit Management, Outcome Management, Volunteer Management, Fundraising Access, Non Profit Intelligence, Action Plans, OmniStudio User, etc.) are all active with 10+ licenses each — none currently consumed.

## Existing data in production

- 1 record in `caseman__Intake__c` — likely a sample from package install. **Need to confirm with Daniel before any destructive action touches it.**
- 1 record in standard `Case` — same; likely sample.
- 0 records in `caseman__Assessment__c`, `caseman__Goal__c`, `pmdm__*__c` objects.
- 0 custom org-local objects.

## Concerns to address before Day 2

1. **Timezone is Pacific (America/Los_Angeles), must change to Eastern (America/Indiana/Indianapolis).** Setup → Company Information. Easy fix, do Day 2.
2. **`clientadvocate@sftsinc.com` is dormant** (no login since 2026-03-10) but holds the only NPC Case Management RUL. Decide whether to keep this user active, reassign the RUL, or repurpose.
3. **Daniel's user (`director@sftsinc.com`) is on the "Program Management Standard User" profile.** He may not have all permissions needed to view/edit everything we'll build. We'll likely create a dedicated permission set ("SFTS Admin Override" or similar) and assign it to him.
4. **Two sample records exist** (1 Intake, 1 Case). Confirm they're test data, not real, and decide whether to delete them in production or leave them alone.
5. **Admin user `admin@sftsinc.com` is what the CLI is authenticated as.** This is the right account for build work. Daniel should keep `director@…` for normal day-to-day work.
