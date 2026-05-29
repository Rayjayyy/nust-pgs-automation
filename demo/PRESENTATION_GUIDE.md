# NUST PGS RPA Demo — Presenter Guide
### ASD810S Assignment II · Robotic Process Automation Suite

---

## Before You Present

### Setup Checklist (do this 15 minutes before the demo)

```
[ ] Python 3.9+ installed and in PATH
[ ] Chrome browser installed
[ ] Open a terminal in C:\...\NUST_PGS\demo\
[ ] Run:  run_demo.bat install          (first time only)
[ ] Test: run_demo.bat server           → open http://127.0.0.1:5000 in browser
[ ] Verify login works: hod@nust.na / password
[ ] Close that browser tab — the bot will open its own window
[ ] Have File Explorer open at:  demo\reports\   (to show files appearing live)
```

---

## Slide-by-Slide Presenter Script

---

### SLIDE 1 — Opening: What is RPA?

> *"Most automation people have seen is UI testing — checking that buttons work.
> RPA is different. RPA **replaces human work**.
> Instead of a person logging in, reading emails, filling forms, routing documents,
> and updating spreadsheets — a bot does it. Silently. At 3am. Every time."*

**Key message:** We are not testing software. We are replacing manual staff tasks with bots.

---

### SLIDE 2 — The Problem We Are Solving

Show the table from the README:

| Manual Task | Time | How Often |
|---|---|---|
| HoD processes approval queue | 30–60 min/day | Daily |
| FPGCR compiles HDC agenda | 2–3 hrs | Weekly |
| Activity report generation | 3–4 hrs | Monthly |
| Supervisor fills SoP template | 45–60 min | Per student |

> *"Every one of these tasks is rules-based. No judgment needed.
> The data exists in the system. The decision criteria are fixed.
> This is exactly what bots are for."*

---

### SLIDE 3 — System Architecture (30 seconds)

```
Student / Supervisor / HoD / FPGCR / FPGC  ←──── Role-based service accounts
        │
        ▼
   NUST Postgraduate Digital System (Laravel 13 + Inertia/React)
        │
        ▼
   Robot Framework 7 + SeleniumLibrary 6    ←──── The RPA bots
        │
        ▼
   CustomLibrary.py                         ←──── Report generation, routing,
                                                   workload analysis, notifications
```

> *"For the demo today, the Laravel system is replaced by a Flask mock server
> that serves the exact same HTML element IDs the bots expect.
> The bots don't know the difference — they see the same page structure."*

---

### SLIDE 4 — Live Demo: Suite 1 — HoD Workflow

**Run command in terminal:**
```
run_demo.bat hod
```

**What to narrate while the bot runs:**

1. *[Login screen appears]*
   > "Watch the bot type the service account credentials. No human does this."

2. *[Pending approvals page loads]*
   > "The bot scans this queue automatically at 08:00 every morning.
   > Previously, the HoD had to check email, open attachments, cross-reference a spreadsheet.
   > The bot does this in 2 seconds."

3. *[Bot opens submission SUB2026001]*
   > "Now the bot reads five evaluation scores off the page.
   > It calculates the average — 84.2 in this case — and compares to the 70-point threshold.
   > It decides: approve."

4. *[Select Approve, fill comments, click submit]*
   > "The approval decision is recorded. The status badge updates.
   > The bot immediately routes the document to the FPGC Representative."

5. *[Notifications logged in the console]*
   > "Three automated emails dispatched: FPGCR, supervisor, and student.
   > The audit trail is in the Robot Framework log.
   > The HoD was not involved at any point."

6. *[Evaluator assignment]*
   > "Now the bot searches for evaluators matching 'Machine Learning'.
   > It checks workload: skips anyone with 5+ active students.
   > Selects the top 2 by expertise match. Confirms the assignment.
   > What used to take 20 minutes of spreadsheet cross-referencing takes 4 seconds."

---

### SLIDE 5 — Live Demo: Suite 2 — Report Generation ⭐ MOST IMPORTANT

**Open File Explorer at `demo\reports\` BEFORE running this.**

**Run command:**
```
run_demo.bat reports
```

**What to narrate:**

1. *[Bot navigates to /admin/reports/weekly]*
   > "The bot logs into the system and goes directly to the metrics dashboard."

2. *[Bot reads metric values from page elements]*
   > "It reads 6 KPI values directly from the live system:
   > 47 students, 23 active submissions, 3 overdue, 8 pending reviews..."

3. *[Console shows 'Calling Generate Faculty Report']*
   > "This is where the magic happens."

4. *[Point to File Explorer — watch the HTML file appear]*
   > "A REAL HTML report just appeared in the reports folder.
   > Open it — it's a properly styled, print-ready faculty report.
   > The bot generated this from live system data in under 3 seconds.
   > Your FPGCR was spending 3 to 4 HOURS doing this manually every month."

5. *[CSV file appears for overdue report]*
   > "The bot also generates the overdue submissions CSV.
   > Look at this — it automatically calculated days overdue and assigned escalation levels:
   > LOW, MEDIUM, or HIGH. Items over 14 days are HIGH.
   > HIGH priority items automatically trigger a notification to the DVC."

6. *[Notification log shown]*
   > "Every email dispatched is logged with timestamp, recipient, subject, and type.
   > This is your audit trail for compliance."

7. *[Archive test]*
   > "The bot archives both reports after distribution.
   > You now have a self-building historical record of every faculty report ever generated."

**Key message:**
> *"The workload analysis test identifies overloaded supervisors automatically.
> Prof. Kaseke has 9 students — the bot flags her for redistribution and notifies the HoD.
> No one had to run a pivot table."*

---

### SLIDE 6 — Live Demo: Suite 3 — Student Intake

**Run command:**
```
run_demo.bat student
```

**What to narrate:**

1. *[Validation test — no browser interaction]*
   > "Before the bot submits anything, it validates completeness.
   > We pass two datasets: one complete, one missing research area and supervisor.
   > The bot rejects the incomplete one — it never enters the review queue.
   > Your committee only sees clean, complete applications."

2. *[Application form auto-fill]*
   > "The bot opens the application form and populates every field from the student record.
   > First name, last name, email, programme, research area, supervisor, personal statement.
   > 7 fields in 4 seconds. Submitted."

3. *[Confirmation page]*
   > "Reference number issued. Status set to Pending Review.
   > Confirmation email dispatched to the student."

4. *[Progress report auto-fill]*
   > "Same pattern for the semester progress report.
   > The bot populates all 5 text fields — including the full research progress narrative —
   > and submits to the supervisor review queue.
   > The supervisor gets an automatic notification."

---

### SLIDE 7 — Opening Generated Reports

After the demo, show the audience the actual output files:

1. **Open `demo\results\report.html`** in Chrome
   - Show pass/fail summary
   - Show timing (all suites complete in < 2 minutes)
   - Click into a failing test to show the screenshot

2. **Open `demo\reports\weekly_faculty_report_2026-05-30.html`** in Chrome
   - Show the NUST-branded HTML report
   - Highlight the metrics table
   - Show "Generated by NUST PG System RPA Bot" footer

3. **Open `demo\reports\overdue_submissions_2026-05-30.csv`** in Excel/Notepad
   - Show the Days Overdue column (auto-calculated)
   - Show the Escalation Level column (HIGH/MEDIUM/LOW)

> *"These files are real. They were generated 2 minutes ago by the bot.
> With the real PGS system, these would contain actual student data."*

---

### SLIDE 8 — Pipeline Summary

Present the two full pipelines from the README:

**Pipeline A — Proposal Registration (8 bots, < 15 minutes)**
```
A1 → A2 → A3 → A4 → A5 → A6 → A7 → A8
     4 working hours manual → replaced
```

**Pipeline B — Thesis Examination (7 bots, < 12 minutes)**
```
B1 → B2 → B3 → B4 → B5 → B6 → B7
     3 working hours manual → replaced
```

> *"End-to-end, from student application to HDC decision,
> the entire pipeline runs unattended.
> Every status update cascades automatically.
> No tracking spreadsheets. No email chains. No missed deadlines."*

---

### SLIDE 9 — Closing

> *"RPA is not about making things faster.
> It's about removing humans from tasks that don't need humans.
> The NUST Postgraduate Office staff should be advising students,
> designing research programs, and improving academic quality —
> not re-typing data between systems and chasing signatures.
> That's what these bots are for."*

---

## Common Questions & Answers

**Q: What if the page layout changes?**
A: We update the element ID in the keyword library. One change, all bots updated.

**Q: Does this work with the real PGS system?**
A: Yes. The keywords use the same element IDs as the real system. Switch `BASE_URL` from `127.0.0.1:5000` to the production URL and the bots run against the live system.

**Q: What is CustomLibrary.py?**
A: A Python Robot Framework library we wrote that handles report generation, workload calculation, routing logic, and notification logging. It's what generates the real HTML and CSV files you can see in the reports folder.

**Q: Can bots run on a schedule?**
A: Yes. Using Windows Task Scheduler or a cron job to call `run_tests.bat` at 08:00 every Friday triggers the weekly report generation automatically, unattended.

**Q: What happens when a bot fails?**
A: Robot Framework captures a screenshot of the failure, logs it in the HTML report, and marks the test FAIL. The suite continues with the remaining tests. Monitoring tools can alert the team on failure.

---

## Running Specific Suites During Q&A

| What to show | Command |
|---|---|
| Just the bot login + queue scan | `run_demo.bat hod` |
| Just the report files being created | `run_demo.bat reports` |
| Just the student form filling | `run_demo.bat student` |
| Everything from scratch | `run_demo.bat` |
| Server only (manual browser demo) | `run_demo.bat server` |

---

*NUST ASD810S Automation Assignment II*
