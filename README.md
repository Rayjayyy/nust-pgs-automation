# NUST PGS — Robotic Process Automation Suite

Robotic Process Automation suite for the **NUST Postgraduate Digital System** — built with [Robot Framework 7](https://robotframework.org) and SeleniumLibrary to automate repetitive institutional business processes end-to-end.

---

## What Is This?

This is an **RPA (Robotic Process Automation)** suite, not a test framework.  
The bots in this suite replace repetitive human tasks — filling forms, routing documents between departments, recording decisions, updating statuses, assigning reviewers, and generating reports — that were previously done manually by staff members across NUST's Postgraduate Office.

> **RPA replaces human effort on repetitive, rules-based tasks.**  
> A bot authenticates as a role-based service account and executes a defined business process automatically — unattended, at any time, without manual intervention.

---

## Automated Business Processes

| Process | Bot Role | What the Bot Automates | Manual Task Replaced |
|---|---|---|---|
| Student Account Provisioning | Admissions | Creates PGS accounts from application records in batch | IT staff manually creating accounts one by one |
| Postgraduate Application Intake | FPGC | Reviews applications, assigns supervisors, rejects ineligible applicants | Committee review sessions with paper application packs |
| SoP Template Compilation & Routing | Supervisor | Fills 15-field SoP template from research record, submits to HoD inbox | Supervisor spending 45–60 min per student filling forms |
| Progress Report Review & Sign-off | Supervisor | Scans review queue, enters comments, applies digital signatures | Reading printed reports, signing, scanning, emailing |
| Evaluator Auto-Assignment | HoD | Matches proposals to available evaluators, sets deadlines, creates assignments | Spreadsheet-based evaluator matching and email notifications |
| Proposal Evaluation & Checklist | Int. Evaluator | Fills evaluation form, completes all checklist items, applies signature | Paper checklist, manual ticking, scanning, filing |
| HoD Decision Recording & Routing | HoD | Records approval decisions, forwards submissions to FPGCR queue | Email chain between HoD and FPGCR secretary |
| Thesis Grading & Examination | Ext. Evaluator | Grades thesis, records remarks, submits to system | Written report sent by post, secretary re-typing into system |
| Honorarium Claim Automation | Ext. Evaluator | Auto-fills 12-field claim form from evaluator profile, routes to HoD | Paper claim form faxed to Finance |
| Claims Approval Processing | HoD | Processes pending claim queue, approves each claim | HoD signing printed claims, scanning, emailing Finance |
| External Examiner Assignment | FPGC | Processes nominations from HoD, creates formal assignment records | Paper nomination forms, Excel tracker updates |
| HDC Agenda Population | FPGCR | Auto-adds approved items to HDC meeting agenda | Manual Word-document agenda compiled from email threads |
| HDC Decision Recording | FPGCR | Records formal HDC decisions with minute references, cascades status | Post-meeting data-entry across 4–6 tables from meeting minutes |
| Activity Report Generation | FPGC | Generates monthly PG activity PDF report, downloads to results folder | 3–4 hour monthly data extraction from 3 systems |
| Status Update Cascade | System-wide | All status transitions happen automatically on decision submission | Manual updates to tracking spreadsheets after each workflow step |

---

## Full Automation Pipelines

### Pipeline A — Proposal Registration Pipeline (8 steps)
Complete lifecycle from new student intake to HDC approval of their research proposal.

```
A1  Admissions bot provisions new student account
A2  FPGC bot reviews application and assigns supervisor
A3  Supervisor bot auto-fills SoP template and routes to HoD
A4  HoD bot auto-assigns internal evaluator
A5  Internal evaluator bot completes evaluation and signs checklist
A6  HoD bot records approval and auto-routes to FPGCR
A7  FPGCR bot evaluates, adds to HDC agenda, and forwards
A8  FPGCR bot records HDC decision — status cascade completes pipeline
```
**Manual effort replaced:** ~4 working hours across 8 staff members  
**Bot run time:** < 15 minutes

### Pipeline B — Thesis Examination Pipeline (7 steps)
Complete lifecycle from progress report submission to HDC examination outcome.

```
B1  Student bot submits semester progress report (20-field template)
B2  Supervisor bot signs progress report and submits thesis to HoD
B3  HoD bot approves thesis, nominates external examiner, routes to FPGCR
B4  FPGC bot formally assigns external examiner
B5  External evaluator bot grades thesis and submits honorarium claim
B6  HoD bot approves honorarium claim
B7  FPGCR bot records final HDC decision — pipeline complete
```
**Manual effort replaced:** ~3 working hours across 7 staff members  
**Bot run time:** < 12 minutes

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Laravel 13 + Fortify (auth) |
| Frontend | Inertia.js + React (TypeScript) + Vite |
| Database | SQLite (dev) / PostgreSQL (prod) |
| RPA engine | Robot Framework 7 + SeleniumLibrary 6 |
| Browser | Google Chrome (via webdriver-manager) |

---

## Project Structure

```
NUST_PGS/
├── tests/
│   ├── 01_authentication/       # Bot credential validation & session management
│   ├── 02_settings/             # Profile sync & security policy automation
│   ├── 02_student/              # Application intake & progress report submission
│   ├── 03_supervisor/           # SoP compilation, progress report review & sign-off
│   ├── 04_internal_evaluator/   # Evaluation queue processing & checklist automation
│   ├── 05_external_evaluator/   # Thesis examination & honorarium claims
│   ├── 06_hod/                  # Decision recording, evaluator assignment & routing
│   ├── 07_fpgcr/                # HDC agenda population & decision recording
│   ├── 08_fpgc/                 # Application processing, examiner assignment & reports
│   └── 09_e2e/                  # Full Pipeline A (8 steps) and Pipeline B (7 steps)
├── resources/                   # Role-based keyword libraries
├── variables/                   # config.py · test_data.py
├── requirements.txt
├── robot.yaml                   # Named RPA task profiles
└── run_tests.bat                # Windows convenience launcher
```

---

## Quick Start

### 1 — Install Python dependencies
```bash
pip install -r requirements.txt
```
Chrome must be installed (webdriver-manager downloads the matching ChromeDriver automatically).

### 2 — Start the Laravel application
```bash
# From the NUST app directory:
php artisan serve --host=127.0.0.1 --port=8000
```

### 3 — Seed the demo service accounts
```bash
php artisan migrate
php artisan db:seed --class=PgsDemoSeeder
```

### 4 — Run the bots

| Goal | Command |
|---|---|
| Validate all bot credentials | `run_tests.bat` |
| Auto-routing & assignment processes | `run_tests.bat routing` |
| Pipeline A — Proposal Registration | `run_tests.bat pipeline-a` |
| Pipeline B — Thesis Examination | `run_tests.bat pipeline-b` |
| Both full pipelines | `run_tests.bat pipelines` |
| Report generation processes | `run_tests.bat reports` |
| Full regression (all processes) | `run_tests.bat full` |

Results land in `results/log.html` — open in any browser for a colour-coded report with screenshots on failure.

---

## RPA Tag Reference

| Tag | Processes included |
|---|---|
| `rpa-auth` | Bot credential validation, session management, 2FA compliance |
| `rpa-intake` | Student application intake, account provisioning, data validation |
| `rpa-routing` | Auto-routing between role queues (SoP, decisions, forwarding) |
| `rpa-assignment` | Auto-assignment of evaluators, supervisors, external examiners |
| `rpa-status` | Automated status recording and cascading updates |
| `rpa-report` | Report generation, download, claims processing |
| `rpa-pipeline` | Full end-to-end pipeline chains (A and B) |
| `pending` | Processes for routes not yet registered in `routes/web.php` |

---

## Service Account Credentials

All demo service accounts share the password **`password`**.

| Role | Email | Bot process |
|---|---|---|
| Student | tendai.moyo@students.nust.na | Application intake, progress reports |
| Supervisor | j.chikwanha@nust.na | SoP compilation, progress review |
| Internal Evaluator | e.kamati@nust.na | Proposal evaluation, checklist |
| Head of Department | hod@nust.na | Decision recording, evaluator assignment |
| External Evaluator | external@nust.na | Thesis grading, honorarium claims |
| FPGC Representative | fpgcr@nust.na | HDC agenda, decision recording |
| FPGC Member | fpgc@nust.na | Application processing, report generation |

---

*NUST ASD810S Automation Assignment*
---
