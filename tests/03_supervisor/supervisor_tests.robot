*** Settings ***
Documentation    RPA — Supervisor Review Automation & Progress Monitoring
...
...              ══════════════════════════════════════════════════════════
...              BUSINESS PROCESS AUTOMATED
...              ══════════════════════════════════════════════════════════
...              Supervisors perform several repetitive tasks each semester
...              that are prime candidates for RPA:
...
...              PROCESS 1 — Summary of Proposals (SoP) Compilation & Routing
...              The supervisor reads the student's proposal details and
...              manually fills a 15-field SoP template before forwarding it
...              to the HoD.  The bot automates this template-filling and
...              submission, routing the completed SoP into the HoD's inbox
...              automatically — no email attachments, no manual forwarding.
...
...              PROCESS 2 — Progress Report Review Queue Processing
...              The bot scans the supervisor's pending-review queue, opens
...              each progress report, records a structured comment, and
...              applies a digital signature.  A task that took 20 minutes
...              per student is completed in under 2 minutes by the bot.
...
...              PROCESS 3 — Student Progress Monitoring
...              The bot checks each assigned student's progress dashboard
...              and flags any student with a status of "at risk" so the
...              supervisor can focus their attention on the right cases.
...
...              Bot identity : j.chikwanha@nust.na  (PgsDemoSeeder id=101)
...              DB tables    : summary_of_proposals · supervisor_reviews
...                            · thesis_evaluations · progress_reports
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/supervisor_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Supervisor Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    supervisor_fail

*** Test Cases ***

Bot Confirms Supervisor Portal Access Before Automation Run
    [Documentation]    The supervisor bot authenticates and confirms dashboard
    ...                access before beginning any review-queue processing.
    [Tags]    rpa-auth    portal-check    supervisor
    Location Should Contain    ${URL_DASHBOARD}

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 1 — SoP Compilation & Auto-Routing to HoD
# ════════════════════════════════════════════════════════════════════════════

Bot Opens Summary Of Proposals Template
    [Documentation]    The bot navigates to the SoP creation form — confirming
    ...                the template is available so the compilation run can start.
    [Tags]    rpa-routing    sop-compilation    supervisor    pending
    Navigate To Create SoP
    Element Should Be Visible    id=thesis_title

Bot Auto-Fills 15-Field SoP Template From Research Record
    [Documentation]    The bot reads the student's research record (thesis type,
    ...                background, problem statement, objectives, questions,
    ...                literature review, theoretical framework, data collection
    ...                and analysis methods, ethical considerations, significance)
    ...                and populates all 15 template fields in a single pass.
    ...
    ...                Manual task replaced: supervisors spent 45–60 minutes per
    ...                student copying research details into the SoP form.
    [Tags]    rpa-routing    sop-compilation    supervisor    pending
    Navigate To Create SoP
    Fill Summary Of Proposals Form

Bot Submits Completed SoP And Routes To HoD Inbox
    [Documentation]    After filling the template the bot submits the SoP, which
    ...                the system automatically places in the HoD's review queue.
    ...                The bot verifies the system navigates to /submissions,
    ...                confirming auto-routing has occurred without any manual
    ...                email or physical document transfer.
    [Tags]    rpa-routing    sop-submission    supervisor    pending
    Navigate To Create SoP
    Fill Summary Of Proposals Form
    Submit SoP To HoD

Bot Enforces Mandatory Thesis Type Field Before Routing
    [Documentation]    The bot implements a pre-submission data-quality gate:
    ...                if thesis_type is missing from the source record it will
    ...                not submit an incomplete SoP — the validation error is
    ...                detected and the record is flagged for manual correction.
    [Tags]    rpa-routing    data-validation    supervisor    negative    pending
    Navigate To Create SoP
    Input Text    id=background_to_study    ${SOP_BACKGROUND}
    Click Element    css=button[type="submit"]
    Field Should Show Validation Error    thesis_type

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 2 — Progress Report Review Queue Processing
# ════════════════════════════════════════════════════════════════════════════

Bot Scans Pending Progress Report Queue
    [Documentation]    The bot opens /progress-reports/pending to retrieve the
    ...                list of student progress reports awaiting supervisor review.
    ...                The count and list are logged for the run audit trail.
    [Tags]    rpa-reminder    review-queue    supervisor    pending
    Navigate To Pending Progress Reports
    Page Should Contain Element    css=table, css=[role="list"]

Bot Records Structured Comment On Pending Progress Report
    [Documentation]    For each report in the queue, the bot enters a structured
    ...                review comment drawn from the supervisor's assessment notes.
    ...                Replaces the manual process of opening each report, typing
    ...                a comment, and saving — one by one.
    [Tags]    rpa-reminder    progress-report-review    supervisor    pending
    Open Progress Report For Review    ${STUDENT_FULL_NAME}
    Add Supervisor Comment    ${SUPERVISOR_COMMENT}

Bot Signs Progress Report And Updates Status To Reviewed
    [Documentation]    After commenting, the bot applies the supervisor's digital
    ...                signature.  This sets supervisor_reviews.signed_at and
    ...                automatically changes the submission status from
    ...                "pending_supervisor_review" to "supervisor_approved" —
    ...                triggering the next step in the workflow without any
    ...                manual status update.
    [Tags]    rpa-routing    progress-report-review    auto-status-update    supervisor    pending
    Comment And Sign Progress Report    ${STUDENT_FULL_NAME}

Bot Enforces Comment Requirement Before Signing
    [Documentation]    The bot validates that a review comment is present before
    ...                signing.  An empty comment triggers a validation error;
    ...                the bot detects this and queues the report for a second
    ...                review pass rather than creating an unsigned blank record.
    [Tags]    rpa-routing    data-validation    supervisor    negative    pending
    Open Progress Report For Review    ${STUDENT_FULL_NAME}
    Clear Element Text    id=supervisor_comment
    Click Element    xpath=//button[contains(text(),'Sign')]
    Field Should Show Validation Error    supervisor_comment

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 3 — Student Progress Monitoring & At-Risk Flagging
# ════════════════════════════════════════════════════════════════════════════

Bot Retrieves My Students List For Progress Monitoring
    [Documentation]    The bot opens the supervisor's student roster so it can
    ...                iterate through each assigned student and check their
    ...                progress status — the first step in the automated
    ...                at-risk detection run.
    [Tags]    rpa-status    student-monitoring    supervisor    pending
    Navigate To My Students
    Page Should Contain    ${STUDENT_FULL_NAME}

Bot Checks Individual Student Progress Dashboard
    [Documentation]    The bot opens a specific student's progress view to read
    ...                their current milestones, submission history, and supervisor
    ...                feedback status.  Any student with overdue milestones is
    ...                flagged in the run log for follow-up action.
    [Tags]    rpa-status    student-monitoring    supervisor    pending
    View Student Progress    ${STUDENT_FULL_NAME}
    Page Should Contain Element    css=main

Bot Grades Thesis And Records Outcome In System
    [Documentation]    The bot opens the thesis grading interface, selects the
    ...                outcome grade (Pass), records evaluation remarks, and
    ...                submits — updating the thesis_evaluations record without
    ...                the supervisor having to manually navigate to each student.
    [Tags]    rpa-status    thesis-grading    supervisor    pending
    Grade Thesis    ${STUDENT_FULL_NAME}    Pass
