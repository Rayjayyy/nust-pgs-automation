*** Settings ***
Documentation    RPA — FPGC Representative: Routing Pipeline & HDC Agenda Automation
...
...              ══════════════════════════════════════════════════════════
...              BUSINESS PROCESS AUTOMATED
...              ══════════════════════════════════════════════════════════
...              The FPGC Representative sits at a critical junction in the
...              postgraduate workflow: submissions arrive from the HoD,
...              must be evaluated, added to the HDC agenda, presented at
...              the Higher Degrees Committee meeting, and the outcome
...              recorded.  Without automation each of these steps requires
...              a manual login, navigation, form-fill, and status update.
...
...              PROCESS 1 — FPGCR Inbox Evaluation & Recommendation
...              The bot processes the FPGCR inbox: for each incoming
...              submission it records the FPGCR's decision and recommendation
...              to HDC, updating the workflow_tasks status automatically.
...
...              PROCESS 2 — HDC Agenda Population
...              The bot adds each approved submission to the HDC meeting
...              agenda (hdc_presentations table), replacing the manual
...              task of maintaining an agenda spreadsheet and notifying
...              committee members by email.
...
...              PROCESS 3 — HDC Decision Recording & Status Cascade
...              After the HDC meeting the bot records the final decision
...              and minute reference for each agenda item — a single run
...              that updates all related submission statuses simultaneously
...              instead of updating them one by one.
...
...              Bot identity : fpgcr@nust.na  (PgsDemoSeeder)
...              DB tables    : hdc_presentations · hdc_decisions
...                            · workflow_tasks (FPGCR_REVIEW, HDC_REVIEW)
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/fpgcr_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      FPGCR Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    fpgcr_fail

*** Test Cases ***

Bot Confirms FPGCR Portal Access Before Processing
    [Documentation]    The FPGCR bot authenticates and confirms dashboard access
    ...                before starting the inbox processing run.
    [Tags]    rpa-auth    portal-check    fpgcr
    Location Should Contain    ${URL_DASHBOARD}

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 1 — FPGCR Inbox Evaluation & Recommendation
# ════════════════════════════════════════════════════════════════════════════

Bot Scans FPGCR Inbox For Submissions Pending Evaluation
    [Documentation]    The bot opens /fpgcr/inbox to see all submissions
    ...                forwarded from the HoD that require FPGCR evaluation
    ...                and recommendation to the Higher Degrees Committee.
    [Tags]    rpa-routing    inbox-scan    fpgcr    pending
    Navigate To FPGCR Inbox
    Page Should Contain Element    css=table

Bot Records FPGCR Recommendation For Each Submission
    [Documentation]    The bot opens each submission, records the FPGCR
    ...                decision (recommended for HDC approval), and submits.
    ...                The workflow_tasks status automatically advances from
    ...                "FPGCR_REVIEW" to "HDC_REVIEW" — no manual update needed.
    ...
    ...                Manual task replaced: the FPGCR sent an email to the
    ...                HDC secretary with a recommendation memo attached.
    ...                The bot creates the digital record directly in the system.
    [Tags]    rpa-routing    recommendation-recording    auto-status-update    fpgcr    pending
    Evaluate And Recommend To HDC    ${STUDENT_FULL_NAME}    approved

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 2 — HDC Agenda Population
# ════════════════════════════════════════════════════════════════════════════

Bot Opens HDC Agenda Management Section
    [Documentation]    The bot navigates to /fpgcr/hdc-agenda — the digital
    ...                equivalent of the paper agenda that was typed up each
    ...                time a new HDC meeting was scheduled.
    [Tags]    rpa-routing    hdc-agenda    fpgcr    pending
    Navigate To HDC Agenda
    Page Should Contain Element    css=main

Bot Auto-Adds Approved Submission To HDC Meeting Agenda
    [Documentation]    The bot creates an hdc_presentations record for the
    ...                approved submission — automatically adding it to the
    ...                upcoming HDC meeting agenda.
    ...
    ...                Manual task replaced: the FPGCR secretary manually
    ...                compiled agenda items from email threads into a Word
    ...                document that was shared before each meeting.
    [Tags]    rpa-routing    hdc-agenda    auto-routing    fpgcr    pending
    Add Item To HDC Agenda    ${STUDENT_FULL_NAME}    sop

Bot Routes Submission To HDC For Final Review
    [Documentation]    The bot forwards the submission to the HDC stage,
    ...                making it visible to committee members in the
    ...                presentations queue.
    [Tags]    rpa-routing    hdc-forwarding    fpgcr    pending
    Forward To HDC    ${STUDENT_FULL_NAME}

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 3 — HDC Decision Recording & Status Cascade
# ════════════════════════════════════════════════════════════════════════════

Bot Opens HDC Presentations Queue
    [Documentation]    The bot opens /fpgcr/presentations to see all agenda
    ...                items that have been presented at an HDC meeting and
    ...                await a formal decision recording.
    [Tags]    rpa-status    hdc-decisions    fpgcr    pending
    Navigate To HDC Presentations
    Page Should Contain Element    css=table

Bot Marks Submission As Presented At HDC Meeting
    [Documentation]    The bot records that the agenda item was presented at the
    ...                HDC meeting by filling in the presentation minutes field —
    ...                replacing the step where the secretary updated the
    ...                spreadsheet after each meeting.
    [Tags]    rpa-status    hdc-decisions    fpgcr    pending
    Mark As Presented    ${STUDENT_FULL_NAME}

Bot Records Final HDC Decision And Cascades Status Update
    [Documentation]    The bot records the HDC's formal decision (approved),
    ...                minute reference number (HDC/2025/06/001), and detailed
    ...                notes.  On submission the system cascades the status
    ...                update to all related records — eliminating the manual
    ...                process of updating 4–6 separate tables after each meeting.
    ...
    ...                This is one of the highest-value automation points in the
    ...                entire workflow: a single bot run replaces 30–40 minutes
    ...                of post-HDC meeting data-entry work.
    [Tags]    rpa-status    hdc-decisions    auto-status-update    fpgcr    pending
    Record HDC Decision    ${STUDENT_FULL_NAME}    approved    HDC/2025/06/001
