*** Settings ***
Documentation    RPA — Faculty PG Committee: Application Processing & Report Generation
...
...              ══════════════════════════════════════════════════════════
...              BUSINESS PROCESS AUTOMATED
...              ══════════════════════════════════════════════════════════
...              The Faculty Postgraduate Committee oversees two key processes
...              that involve high volumes of repetitive decision-making:
...
...              PROCESS 1 — Application Review & Supervisor Assignment
...              Each semester the FPGC receives a batch of postgraduate
...              applications, reviews them against admission criteria, and
...              assigns each accepted student to an appropriate supervisor.
...              The bot processes the entire batch in one unattended run —
...              replacing manual review sessions that previously took half
...              a working day per intake cycle.
...
...              PROCESS 2 — External Examiner Assignment
...              When the HoD nominates an external examiner for a thesis
...              the FPGC must formally assign them.  The bot processes all
...              pending nominations in one run, creating the assignment
...              records and notifying the relevant parties automatically.
...
...              PROCESS 3 — Postgraduate Activity Report Generation
...              The FPGC generates a monthly activity report for the
...              faculty leadership.  The bot triggers report generation,
...              waits for the PDF to be compiled, and downloads it to
...              the reports folder — replacing the manual process of
...              pulling data from three systems and formatting a Word doc.
...
...              Bot identity : fpgc@nust.na  (PgsDemoSeeder)
...              DB tables    : pg_applications · application_reviews
...                            · supervision_relationships · evaluator_assignments
...                            · report_snapshots
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/fpgc_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      FPGC Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    fpgc_fail

*** Test Cases ***

Bot Confirms FPGC Portal Access Before Processing Intake
    [Documentation]    The FPGC bot authenticates and confirms dashboard access
    ...                before beginning the application batch processing run.
    [Tags]    rpa-auth    portal-check    fpgc
    Location Should Contain    ${URL_DASHBOARD}

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 1 — Application Review & Supervisor Assignment
# ════════════════════════════════════════════════════════════════════════════

Bot Opens Application Intake Queue
    [Documentation]    The bot opens /fpgc/applications to retrieve the batch
    ...                of postgraduate applications awaiting FPGC review.
    ...                The queue count is logged to track intake volume.
    [Tags]    rpa-intake    application-queue    fpgc    pending
    Navigate To Applications
    Page Should Contain Element    css=table

Bot Reviews Application Details Before Decision
    [Documentation]    The bot opens a specific application and reads the
    ...                programme field — confirming application data is
    ...                complete before recording a decision.
    [Tags]    rpa-intake    application-review    fpgc    pending
    Open Application    ${STUDENT_FULL_NAME}
    Review Application Details

Bot Assigns Supervisor And Approves Application
    [Documentation]    The bot selects the appropriate supervisor from the
    ...                dropdown (mapped to supervision_relationships) and
    ...                submits the "Select for Supervision" action.
    ...
    ...                Manual task replaced: committee members brought printed
    ...                application packs to meetings, voted on each one, and
    ...                the secretary then updated the database from meeting
    ...                minutes.  The bot applies decisions in real time.
    [Tags]    rpa-routing    supervisor-assignment    auto-routing    fpgc    pending
    Select Student For Supervision
    ...    applicant_name=${STUDENT_FULL_NAME}
    ...    supervisor_name=${SUPERVISOR_FULL_NAME}

Bot Routes Rejected Application With Reason
    [Documentation]    Applications that do not meet admission requirements are
    ...                rejected by the bot with a structured reason recorded in
    ...                application_reviews — replacing the process of writing
    ...                rejection letters and updating a spreadsheet.
    [Tags]    rpa-intake    application-rejection    fpgc    pending
    Reject Application
    ...    applicant_name=${STUDENT_FULL_NAME}
    ...    reason=Does not meet minimum entry requirements for the programme.

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 2 — External Examiner Assignment
# ════════════════════════════════════════════════════════════════════════════

Bot Opens External Examiner Assignment Queue
    [Documentation]    The bot navigates to /fpgc/external-examiners to see
    ...                all pending HoD nominations awaiting formal FPGC
    ...                assignment.
    [Tags]    rpa-assignment    external-examiner    fpgc    pending
    Navigate To External Examiner Assignments
    Page Should Contain Element    css=main

Bot Formally Assigns External Examiner From HoD Nomination
    [Documentation]    The bot selects the HoD-nominated external examiner from
    ...                the dropdown and creates the evaluator_assignments record.
    ...                This triggers an automated notification to the examiner
    ...                and updates the thesis status to "examiner_assigned" —
    ...                replacing the formal letter of appointment previously sent
    ...                by post.
    [Tags]    rpa-assignment    external-examiner    auto-routing    fpgc    pending
    Assign External Examiner
    ...    student_name=${STUDENT_FULL_NAME}
    ...    examiner_name=${EXT_EVAL_FULL_NAME}

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 3 — Postgraduate Activity Report Generation
# ════════════════════════════════════════════════════════════════════════════

Bot Opens Report Generation Section
    [Documentation]    The bot navigates to /fpgc/reports — the starting point
    ...                for the automated monthly report generation run.
    [Tags]    rpa-report    report-generation    fpgc    pending
    Navigate To Reports
    Page Should Contain Element    css=main

Bot Generates Monthly Postgraduate Activity Report
    [Documentation]    The bot triggers the report_snapshots generation process,
    ...                which compiles data from pg_applications, submissions,
    ...                hdc_decisions, and thesis_evaluations into a single PDF.
    ...
    ...                Manual task replaced: the faculty administrator spent
    ...                3–4 hours each month extracting data from multiple
    ...                spreadsheets and system exports to compile the report.
    ...                The bot generates the same report in under 30 seconds.
    [Tags]    rpa-report    report-generation    fpgc    pending
    Generate Postgraduate Activity Report

Bot Downloads Generated Report For Distribution
    [Documentation]    After generation the bot downloads the report file to
    ...                the automation results folder.  The downloaded file can
    ...                then be automatically attached to the monthly faculty
    ...                report email in the next step of the automation chain.
    [Tags]    rpa-report    report-download    fpgc    pending
    Download Report
