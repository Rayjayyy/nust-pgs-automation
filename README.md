# NUST PGS – Robot Framework Automation Suite

Automated test suite for the **NUST Postgraduate Digital System** built with [Robot Framework](https://robotframework.org) and SeleniumLibrary.

## Tech Stack
| Layer | Technology |
|---|---|
| Backend | Laravel 13 + Fortify (auth) |
| Frontend | Inertia.js + React (TypeScript) + Vite |
| Database | SQLite (dev) / PostgreSQL (prod) |
| Test runner | Robot Framework 7 + SeleniumLibrary 6 |
| Browser | Google Chrome (via webdriver-manager) |

## Project Structure
```
NUST_PGS/
├── tests/
│   ├── 01_authentication/   # Login, registration, password reset
│   ├── 02_settings/         # Profile & security settings
│   ├── 03_supervisor/       # Supervisor module
│   ├── 04_internal_evaluator/
│   ├── 05_external_evaluator/
│   ├── 06_hod/              # Head of Department
│   ├── 07_fpgcr/            # FPGC Representative
│   ├── 08_fpgc/             # Faculty PG Committee
│   └── 09_e2e/              # End-to-end workflow chains
├── resources/               # Keyword libraries (one per role)
├── variables/               # config.py · test_data.py
├── requirements.txt
└── robot.yaml               # Named task profiles
```

## Quick Start

### 1 – Prerequisites
```bash
pip install -r requirements.txt
```
Chrome must be installed (webdriver-manager auto-downloads the matching ChromeDriver).

### 2 – Start the Laravel app
```bash
# From the NUST app directory:
php artisan serve --host=127.0.0.1 --port=8000
```

### 3 – Run the tests

| Goal | Command |
|---|---|
| Smoke tests (auth + settings only) | `robot --outputdir results --include smoke tests/` |
| Skip unimplemented pages | `robot --outputdir results --exclude pending tests/` |
| Auth + settings suite | `robot --outputdir results tests/01_authentication/ tests/02_settings/` |
| Full regression (when all routes ship) | `robot --outputdir results tests/` |

Results land in `results/log.html` — open in any browser for a colour-coded report with screenshots on failure.

## Tag Strategy
| Tag | Meaning |
|---|---|
| `smoke` | Critical-path tests against currently-shipped pages |
| `regression` | Full regression including boundary/negative tests |
| `pending` | Tests for business-module pages not yet in `routes/web.php` |
| `e2e` | Multi-role end-to-end workflow chains |

## Demo Credentials
All demo users share the password **`password`**.

| Role | Email |
|---|---|
| Student | tendai.moyo@students.nust.na |
| Supervisor | j.chikwanha@nust.na |
| Internal Evaluator | e.kamati@nust.na |
| Head of Department | hod@nust.na |
| External Evaluator | external@nust.na |
| FPGC Representative | fpgcr@nust.na |
| FPGC Member | fpgc@nust.na |

## Automated Processes
| Module | What the bot does |
|---|---|
| Authentication | Login for all 7 roles, registration, password reset, 2FA, logout, guest-redirect |
| Settings | Profile update, password change, 2FA toggle |
| Student | Submit progress report (20-field template) |
| Supervisor | Submit Summary of Proposals (15-field template), sign progress report |
| Internal Evaluator | Evaluate proposal, complete & sign checklist |
| HoD | Assign evaluator, record decision, forward to FPGC-R, propose external examiner, approve claims |
| FPGC-R | Evaluate submission, add to HDC agenda, forward, record HDC decision |
| FPGC | Review applications, select for supervision, assign external examiner, generate report |
| E2E Workflow A | Full proposal pipeline (8 steps, all roles) |
| E2E Workflow B | Full thesis examination pipeline (7 steps, all roles) |

---
*NUST ASD810S Automation Assignment*
