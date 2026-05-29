*** Settings ***
Documentation       DEMO Suite 2 — Automated Report Generation & Distribution
...
...                 *** THE MOST IMPORTANT DEMO SUITE ***
...
...                 What this shows:
...                   • Bot navigates to the PGS dashboard and scrapes live metrics
...                   • Bot calls CustomLibrary.py → generates a REAL HTML report on disk
...                   • Bot generates a REAL CSV report of overdue submissions
...                   • Bot retrieves committee email list from the system
...                   • Bot dispatches simulated emails to all committee members
...                   • Bot archives reports to the archive folder
...                   • All output files are inspectable AFTER the demo run
...
...                 Manual effort replaced:
...                   "3–4 hour monthly data extraction from 3 separate systems,
...                    compiled into a Word document, emailed to committee members."
...                   — This bot does the entire task in under 30 seconds.

Metadata            Suite         Demo — Report Generation
Metadata            Version       1.0
Metadata            Author        ASD810S Assignment II

Library             SeleniumLibrary
Library             OperatingSystem
Library             Collections
Library             ${CURDIR}/../libraries/CustomLibrary.py
Resource            ${CURDIR}/../resources/demo_common.robot

Suite Setup         Open Demo Browser
Suite Teardown      Close All Browsers
Test Setup          Go To Page    ${BASE_URL}/login
Test Teardown       Run Keyword If Test Failed    Capture Page Screenshot    EMBED

*** Variables ***
${REPORT_DATE}          2026-05-30

*** Test Cases ***

# =============================================================================
# TC-DEMO-RPT-001 — REAL HTML Report Generated From Live System Data
# =============================================================================
TC-DEMO-RPT-001 Bot Collects Live Metrics And Generates Weekly HTML Faculty Report
    [Documentation]    The bot logs into the PGS system, navigates to the metrics
    ...                dashboard, reads 6 KPI values directly from the page, then calls
    ...                CustomLibrary.Generate Faculty Report to produce a REAL HTML file
    ...                with embedded styling and a metrics table.
    ...
    ...                After this test you can open:
    ...                  demo/reports/weekly_faculty_report_2026-05-30.html
    ...                in any browser to see the generated output.
    [Tags]    demo    reports    rpa-report    weekly    most-important

    Log    ══════════════════════════════════════════════════════════════════    level=INFO
    Log    [BOT] TC-DEMO-RPT-001 Starting                                      level=INFO
    Log    [BOT] Task: collect metrics → generate REAL HTML report             level=INFO
    Log    ══════════════════════════════════════════════════════════════════    level=INFO

    # ── Step 1: Navigate to the weekly metrics dashboard ────────────────────
    Login As HoD
    Go To Page    ${BASE_URL}/admin/reports/weekly
    Wait Until Element Is Visible    id=metric-total-students    timeout=10
    Log    [BOT] Connected to live metrics dashboard    level=INFO

    # ── Step 2: Collect all KPIs from the system ────────────────────────────
    ${students}=    Get Text    id=metric-total-students
    ${active}=      Get Text    id=metric-active-submissions
    ${overdue}=     Get Text    id=metric-overdue-submissions
    ${pending}=     Get Text    id=metric-pending-reviews
    ${completed}=   Get Text    id=metric-completed-this-week
    ${workload}=    Get Text    id=metric-supervisor-workload-avg

    Log    [BOT] ┌─ LIVE METRICS COLLECTED ─────────────────────────┐    level=INFO
    Log    [BOT] │  Total PG Students       : ${students}            │    level=INFO
    Log    [BOT] │  Active Submissions      : ${active}              │    level=INFO
    Log    [BOT] │  Overdue Submissions     : ${overdue}             │    level=INFO
    Log    [BOT] │  Pending Reviews         : ${pending}             │    level=INFO
    Log    [BOT] │  Completed This Week     : ${completed}           │    level=INFO
    Log    [BOT] │  Avg Supervisor Workload : ${workload}            │    level=INFO
    Log    [BOT] └──────────────────────────────────────────────────┘    level=INFO

    # ── Step 3: Build report data and GENERATE REAL HTML FILE ───────────────
    ${report_data}=    Create Dictionary
    ...    total_students=${students}
    ...    active_submissions=${active}
    ...    overdue_submissions=${overdue}
    ...    pending_reviews=${pending}
    ...    completed_this_week=${completed}
    ...    supervisor_workload_avg=${workload}

    ${html_path}=    Set Variable
    ...    ${REPORT_DIR}/weekly_faculty_report_${REPORT_DATE}.html

    Log    [BOT] Calling Generate Faculty Report → writing HTML to disk    level=INFO

    ${report_path}=    Generate Faculty Report
    ...    report_data=${report_data}
    ...    report_type=weekly
    ...    output_path=${html_path}

    # ── Step 4: Verify the file was ACTUALLY created ─────────────────────────
    File Should Exist    ${report_path}
    Log    [BOT] HTML report file created: ${report_path}    level=INFO

    ${content}=    Get File    ${report_path}
    Should Contain    ${content}    NUST Postgraduate Faculty Report
    Should Contain    ${content}    Total Students
    Should Contain    ${content}    Overdue Submissions
    Log    [BOT] Report content verified — all required sections present    level=INFO

    # ── Step 5: Store path for subsequent tests ──────────────────────────────
    Set Suite Variable    ${WEEKLY_REPORT_PATH}    ${report_path}
    Log    [BOT] Report ready: ${report_path}    level=INFO
    Log    [REPLACED] 3-4 hour manual data extraction now takes < 30 seconds    level=INFO


# =============================================================================
# TC-DEMO-RPT-002 — REAL CSV Overdue Report With Escalation Triage
# =============================================================================
TC-DEMO-RPT-002 Bot Generates Overdue Submissions CSV With Escalation Levels
    [Documentation]    The bot builds overdue submission records from system data,
    ...                calls CustomLibrary.Generate Overdue Submission Report to produce
    ...                a REAL CSV file with Days Overdue and Escalation Level columns
    ...                automatically calculated from the due dates.
    ...
    ...                After this test you can open:
    ...                  demo/reports/overdue_submissions_2026-05-30.csv
    ...                in Excel to see the generated output.
    [Tags]    demo    reports    rpa-report    overdue    most-important

    Log    ══════════════════════════════════════════════════════════════════    level=INFO
    Log    [BOT] TC-DEMO-RPT-002 Starting                                      level=INFO
    Log    [BOT] Task: generate CSV of overdue submissions with escalation triage    level=INFO
    Log    ══════════════════════════════════════════════════════════════════    level=INFO

    # Build overdue submission records (in production these are read from the DB)
    ${overdue_records}=    Create List

    ${r1}=    Create Dictionary
    ...    student_id=PG2026003
    ...    student_name=Amara Nkosi
    ...    submission_type=Progress Report
    ...    due_date=2026-05-10
    ...    supervisor=SUP002
    ...    last_action=reminder_sent

    ${r2}=    Create Dictionary
    ...    student_id=PG2026007
    ...    student_name=Sipho Dube
    ...    submission_type=Thesis
    ...    due_date=2026-05-01
    ...    supervisor=SUP001
    ...    last_action=none

    ${r3}=    Create Dictionary
    ...    student_id=PG2026012
    ...    student_name=Rudo Chigwedere
    ...    submission_type=Table of Changes
    ...    due_date=2026-05-22
    ...    supervisor=SUP003
    ...    last_action=escalated

    Append To List    ${overdue_records}    ${r1}
    Append To List    ${overdue_records}    ${r2}
    Append To List    ${overdue_records}    ${r3}

    Log    [BOT] Processing ${3} overdue records    level=INFO

    # Generate REAL CSV file via CustomLibrary.py
    ${csv_path}=    Set Variable
    ...    ${REPORT_DIR}/overdue_submissions_${REPORT_DATE}.csv

    Log    [BOT] Calling Generate Overdue Submission Report → writing CSV    level=INFO

    ${report_path}=    Generate Overdue Submission Report
    ...    overdue_data=${overdue_records}
    ...    output_path=${csv_path}

    # Verify the CSV was created
    File Should Exist    ${report_path}
    Log    [BOT] CSV file created: ${report_path}    level=INFO

    ${content}=    Get File    ${report_path}
    Should Contain    ${content}    Days Overdue
    Should Contain    ${content}    Escalation Level
    Should Contain    ${content}    Amara Nkosi
    Log    [BOT] CSV content verified — escalation levels auto-calculated    level=INFO

    # Auto-escalate high-priority items
    Clear Notification Log
    ${lines}=    Split String    ${content}    \n
    FOR    ${line}    IN    @{lines}
        ${is_high}=    Run Keyword And Return Status    Should Contain    ${line}    HIGH
        IF    ${is_high} and '${line}' != 'Student ID,Student Name,Submission Type,Due Date,Days Overdue,Supervisor,Last Action,Escalation Level'
            Log    [BOT] HIGH priority item detected — escalating to DVC    level=INFO
            Send Email Notification
            ...    recipient=dvc-tlu@nust.na
            ...    subject=HIGH PRIORITY: Overdue Submission Escalation
            ...    body=High priority overdue submission detected in report ${report_path}. Immediate action required.
            ...    notification_type=${NOTIF_ESCALATION}
        END
    END

    ${log}=    Get Notification Log
    ${esc}=    Evaluate    [n for n in ${log} if n['type'] == '${NOTIF_ESCALATION}']
    ${esc_c}=    Get Length    ${esc}
    Log    [BOT] ${esc_c} high-priority escalation(s) sent to DVC    level=INFO

    Set Suite Variable    ${OVERDUE_REPORT_PATH}    ${report_path}
    Log    [REPLACED] Manual overdue tracking spreadsheet and email chains    level=INFO


# =============================================================================
# TC-DEMO-RPT-003 — Bot Distributes Report To Committee Via Email Automation
# =============================================================================
TC-DEMO-RPT-003 Bot Retrieves Committee Emails And Distributes Weekly Report
    [Documentation]    The bot navigates to the committee contacts page, scrapes the
    ...                email list, and dispatches individualised report notifications
    ...                to every FPGC and HDC committee member — replacing the FPGCR's
    ...                manual task of emailing each member separately.
    [Tags]    demo    reports    rpa-report    notification

    Log    ══════════════════════════════════════════════════════════════════    level=INFO
    Log    [BOT] TC-DEMO-RPT-003 Starting                                      level=INFO
    Log    [BOT] Task: get committee emails from system → dispatch report links    level=INFO
    Log    ══════════════════════════════════════════════════════════════════    level=INFO

    Login As HoD
    Clear Notification Log

    # Step 1: Retrieve committee email addresses from system
    Go To Page    ${BASE_URL}/admin/committee/contacts
    Wait Until Element Is Visible    class=committee-email    timeout=10

    ${email_els}=    Get WebElements    class=committee-email
    ${emails}=       Create List
    FOR    ${el}    IN    @{email_els}
        ${addr}=    Get Text    ${el}
        Append To List    ${emails}    ${addr}
        Log    [BOT] Committee member found: ${addr}    level=INFO
    END

    ${email_count}=    Get Length    ${emails}
    Log    [BOT] Retrieved ${email_count} committee email addresses    level=INFO
    Should Be True    ${email_count} >= 3

    # Step 2: Dispatch personalised notifications to each member
    FOR    ${email}    IN    @{emails}
        Send Email Notification
        ...    recipient=${email}
        ...    subject=Weekly Faculty Report — ${REPORT_DATE}
        ...    body=Please find attached the weekly faculty activity report. Overdue submissions: 3. Pending reviews: 8. Full report available in the PGS system.
        ...    notification_type=${NOTIF_REMINDER}

        Log    [BOT] Report notification dispatched → ${email}    level=INFO
    END

    # Step 3: Verify all notifications were logged
    ${log}=    Get Notification Log
    ${report_notifs}=    Evaluate    [n for n in ${log} if 'Weekly Faculty Report' in n['subject']]
    ${sent_count}=    Get Length    ${report_notifs}
    Should Be Equal As Integers    ${sent_count}    ${email_count}
    Log    [BOT] All ${sent_count} committee notifications confirmed in audit log    level=INFO
    Log    [REPLACED] FPGCR manually emailing each committee member individually    level=INFO


# =============================================================================
# TC-DEMO-RPT-004 — Bot Archives Report After Distribution
# =============================================================================
TC-DEMO-RPT-004 Bot Archives Generated Report To Archive Directory
    [Documentation]    After distribution, the bot copies the report to the archive
    ...                directory and verifies both the original and archive copy exist.
    ...                The archive builds an automatic historical record.
    [Tags]    demo    reports    rpa-report    archive

    Log    ══════════════════════════════════════════════════════════════════    level=INFO
    Log    [BOT] TC-DEMO-RPT-004 Starting                                      level=INFO
    Log    [BOT] Task: archive report after distribution                       level=INFO
    Log    ══════════════════════════════════════════════════════════════════    level=INFO

    # Ensure a report exists to archive (generate one if suite variable not set)
    ${has_report}=    Run Keyword And Return Status
    ...    Variable Should Exist    ${WEEKLY_REPORT_PATH}

    IF    not ${has_report}
        ${report_data}=    Create Dictionary
        ...    total_students=47    active_submissions=23
        ...    overdue_submissions=3    pending_reviews=8
        ...    completed_this_week=5    supervisor_workload_avg=4.7
        ${rp}=    Generate Faculty Report
        ...    report_data=${report_data}
        ...    report_type=weekly
        ...    output_path=${REPORT_DIR}/weekly_faculty_report_${REPORT_DATE}.html
        Set Suite Variable    ${WEEKLY_REPORT_PATH}    ${rp}
    END

    File Should Exist    ${WEEKLY_REPORT_PATH}
    Log    [BOT] Source report confirmed: ${WEEKLY_REPORT_PATH}    level=INFO

    # Archive the report
    ${archive_dir}=    Set Variable    ${REPORT_DIR}/archive
    Create Directory    ${archive_dir}

    ${filename}=    Evaluate    __import__('os').path.basename('${WEEKLY_REPORT_PATH}')
    ${archive_path}=    Set Variable    ${archive_dir}/${filename}

    Copy File    ${WEEKLY_REPORT_PATH}    ${archive_path}
    Log    [BOT] Report archived to: ${archive_path}    level=INFO

    # Verify BOTH original and archive exist
    File Should Exist    ${WEEKLY_REPORT_PATH}
    File Should Exist    ${archive_path}
    Log    [BOT] Archive verified — original intact, archive copy confirmed    level=INFO
    Log    [REPLACED] Manual archive: FPGCRs emailing reports to a shared folder    level=INFO


# =============================================================================
# TC-DEMO-RPT-005 — Supervisor Workload Analysis
# =============================================================================
TC-DEMO-RPT-005 Bot Calculates Supervisor Workload And Flags Overloaded Staff
    [Documentation]    The bot uses CustomLibrary.Calculate Supervisor Workload to analyse
    ...                supervisor assignments, compute workload scores, and identify
    ...                overloaded supervisors who need student redistribution.
    [Tags]    demo    reports    rpa-report    workload

    Log    ══════════════════════════════════════════════════════════════════    level=INFO
    Log    [BOT] TC-DEMO-RPT-005 Starting                                      level=INFO
    Log    [BOT] Task: analyse supervisor workload and identify overloaded staff    level=INFO
    Log    ══════════════════════════════════════════════════════════════════    level=INFO

    # Build supervisor assignment data
    ${data}=    Create List

    # Supervisor 1: J. Chikwanha — 3 students (2 pending review, 0 overdue)
    FOR    ${i}    IN    1    2    3
        ${e}=    Create Dictionary
        ...    supervisor_id=SUP001
        ...    supervisor_name=Dr. J. Chikwanha
        ...    review_status=pending
        ...    approval_status=approved
        Append To List    ${data}    ${e}
    END

    # Supervisor 2: A. Kaseke — 8 students (5 pending, 3 overdue) — OVERLOADED
    FOR    ${i}    IN    1    2    3    4    5    6    7    8
        ${rv}=    Set Variable    overdue
        IF    ${i} <= 5
            ${rv}=    Set Variable    pending
        END
        ${e}=    Create Dictionary
        ...    supervisor_id=SUP002
        ...    supervisor_name=Prof. A. Kaseke
        ...    review_status=${rv}
        ...    approval_status=pending
        Append To List    ${data}    ${e}
    END

    # Supervisor 3: E. Kamati — 2 students (available for more)
    FOR    ${i}    IN    1    2
        ${e}=    Create Dictionary
        ...    supervisor_id=SUP003
        ...    supervisor_name=Dr. E. Kamati
        ...    review_status=completed
        ...    approval_status=approved
        Append To List    ${data}    ${e}
    END

    # Compute workload scores using CustomLibrary.py
    ${analysis}=    Calculate Supervisor Workload    ${data}

    Log    [BOT] Average workload: ${analysis}[average_workload] students/supervisor    level=INFO
    Log    [BOT] Overloaded supervisors: ${analysis}[overloaded_count]    level=INFO

    FOR    ${sup_id}    IN    @{analysis}[supervisors]
        ${sup}=    Get From Dictionary    ${analysis}[supervisors]    ${sup_id}
        Log    [BOT] ${sup}[supervisor_name]: ${sup}[total_students] students | score:${sup}[workload_score] | ${sup}[recommendation]    level=INFO

        IF    ${sup}[is_overloaded]
            Log    [BOT] ⚠ OVERLOADED: ${sup}[supervisor_name] — redistribution recommended    level=WARN
            Send Email Notification
            ...    recipient=hod@nust.na
            ...    subject=Supervisor Workload Alert — ${sup}[supervisor_name]
            ...    body=${sup}[supervisor_name] is overloaded (${sup}[total_students] students). Recommend immediate student redistribution.
            ...    notification_type=${NOTIF_ESCALATION}
        END
    END

    Should Be True    ${analysis}[overloaded_count] >= 1
    Log    [REPLACED] HoD manually reviewing spreadsheets to identify workload imbalances    level=INFO

*** Keywords ***
# No additional keywords needed — all helpers are in demo_common.robot
