*** Settings ***
Documentation    RPA — Head of Department Decision Automation & Evaluator Assignment
...
...              ══════════════════════════════════════════════════════════
...              BUSINESS PROCESS AUTOMATED
...              ══════════════════════════════════════════════════════════
...              The Head of Department performs four high-volume, repetitive
...              administrative processes that this suite automates:
...
...              PROCESS 1 — Submission Inbox Batch Processing
...              The bot opens the HoD inbox, processes each pending
...              submission, and records an approval decision — replacing
...              the manual review-and-email cycle with an automated
...              decision-recording run.
...
...              PROCESS 2 — Auto-Assignment of Internal Evaluators
...              The bot matches approved proposals to available internal
...              evaluators and creates evaluator_assignments records with a
...              standardised deadline — eliminating the manual matching
...              spreadsheet used to track which evaluator is assigned to
...              which student.
...
...              PROCESS 3 — Auto-Routing to FPGC Representative
...              After approving a submission the bot forwards it to the
...              FPGC-R queue automatically — replacing the step where the
...              HoD secretary emailed the FPGCR to notify them of a new item.
...
...              PROCESS 4 — Honorarium Claim Queue Processing
...              The bot opens the claims management page and processes all
...              pending evaluator claims in one run — replacing the process
...              of opening each claim email, checking it against the
...              examiner record, and manually approving in the system.
...
...              Bot identity : hod@nust.na  (PgsDemoSeeder)
...              DB tables    : evaluator_assignments · hod_decisions
...                            · external_examiner_proposals · honorarium_claims
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/hod_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      HoD Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    hod_fail

*** Test Cases ***

Bot Confirms HoD Portal Access Before Processing Queues
    [Documentation]    The HoD bot authenticates and confirms dashboard
    ...                access before beginning any queue-processing run.
    [Tags]    rpa-auth    portal-check    hod
    Location Should Contain    ${URL_DASHBOARD}

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 1 — Submission Inbox Batch Processing
# ════════════════════════════════════════════════════════════════════════════

Bot Scans HoD Submission Inbox For Pending Items
    [Documentation]    The bot opens /hod/inbox to retrieve the list of
    ...                submissions awaiting HoD review.  The count is logged
    ...                so the department can track workload over time.
    [Tags]    rpa-status    inbox-processing    hod    pending
    Navigate To HoD Inbox
    Page Should Contain Element    css=table

Bot Opens Submission Record For Review
    [Documentation]    The bot opens a specific student's submission record —
    ...                the first step in the automated decision-recording run.
    [Tags]    rpa-status    inbox-processing    hod    pending
    Open Submission    ${STUDENT_FULL_NAME}
    Page Should Contain Element    css=main

Bot Records Approval Decision And Updates Status
    [Documentation]    The bot records an "approved" decision in the hod_decisions
    ...                table, which automatically updates the submission status.
    ...                This replaces the HoD manually noting a decision in a
    ...                paper register and emailing the graduate office to update
    ...                the student's record.
    [Tags]    rpa-status    decision-recording    auto-status-update    hod    pending
    Record HoD Decision    ${STUDENT_FULL_NAME}    approved

Bot Processes Revision-Required Decision In Batch
    [Documentation]    For submissions that need corrections the bot records a
    ...                "revisions_required" decision — automatically triggering
    ...                a notification to the student and supervisor through the
    ...                workflow_tasks table.
    [Tags]    rpa-status    decision-recording    hod    pending
    Record HoD Decision    ${STUDENT_FULL_NAME}    revisions_required

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 2 — Auto-Assignment of Internal Evaluators
# ════════════════════════════════════════════════════════════════════════════

Bot Auto-Assigns Available Internal Evaluator To Approved Proposal
    [Documentation]    The bot selects the most appropriate available evaluator
    ...                (Dr. Kamati — e.kamati@nust.na) and creates an
    ...                evaluator_assignments record with a standard 30-day
    ...                deadline.
    ...
    ...                Manual task replaced: the HoD secretary maintained a
    ...                spreadsheet of evaluator assignments and sent individual
    ...                emails to notify each evaluator.  The bot assigns and
    ...                notifies in one automated step.
    [Tags]    rpa-assignment    evaluator-assignment    hod    pending
    Assign Internal Evaluator    ${STUDENT_FULL_NAME}    ${INT_EVAL_FULL_NAME}

Bot Enforces Evaluator Selection Before Assignment Commit
    [Documentation]    The bot validates that an evaluator has been selected
    ...                before creating the assignment record — preventing
    ...                "orphan" assignment records with no linked evaluator.
    [Tags]    rpa-assignment    data-validation    hod    negative    pending
    Open Submission    ${STUDENT_FULL_NAME}
    Click Element    css=button[type="submit"]
    Field Should Show Validation Error    internal_evaluator

Bot Proposes External Examiner For Thesis-Stage Submission
    [Documentation]    When a thesis reaches the examination stage the bot
    ...                creates an external_examiner_proposals record with the
    ...                proposed examiner's name, institution, and email —
    ...                replacing the paper nomination form previously submitted
    ...                to the FPGCR by post.
    [Tags]    rpa-assignment    external-examiner    hod    pending
    Propose External Evaluator
    ...    student_name=${STUDENT_FULL_NAME}
    ...    evaluator_name=${EXT_EVAL_FULL_NAME}
    ...    institution=${EXT_EVAL_INSTITUTION}
    ...    email=${EXT_EVAL_EMAIL}

Bot Validates Examiner Email Before Submitting Nomination
    [Documentation]    The bot confirms the email field is present and non-empty
    ...                before submitting the examiner nomination — preventing
    ...                nominations with missing contact details.
    [Tags]    rpa-assignment    data-validation    hod    negative    pending
    Open Submission    ${STUDENT_FULL_NAME}
    Input Text    id=proposed_evaluator_name         ${EXT_EVAL_FULL_NAME}
    Input Text    id=proposed_evaluator_institution  ${EXT_EVAL_INSTITUTION}
    Click Element    css=button[type="submit"]
    Field Should Show Validation Error    proposed_evaluator_email

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 3 — Auto-Routing to FPGC Representative
# ════════════════════════════════════════════════════════════════════════════

Bot Auto-Routes Approved Submission To FPGCR Queue
    [Documentation]    After recording an approval decision the bot forwards
    ...                the submission to the FPGCR queue in one click — the
    ...                equivalent of the HoD's secretary printing the cover
    ...                sheet and physically delivering the file to the FPGCR.
    ...                The bot confirms the page returns to /hod/inbox,
    ...                indicating the item has been removed from the HoD queue
    ...                and is now in the FPGCR queue.
    [Tags]    rpa-routing    auto-routing    hod    pending
    Forward To FPGCR    ${STUDENT_FULL_NAME}

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 4 — Honorarium Claim Queue Processing
# ════════════════════════════════════════════════════════════════════════════

Bot Opens Claims Management Queue
    [Documentation]    The bot opens /hod/claims to retrieve the list of
    ...                honorarium claims awaiting HoD approval.
    [Tags]    rpa-report    claims-processing    hod    pending
    Navigate To Claims Management
    Page Should Contain Element    css=table

Bot Approves Pending Evaluator Honorarium Claim
    [Documentation]    The bot finds the pending claim for the external evaluator
    ...                and approves it — updating the honorarium_claims.status
    ...                to "approved" and making the claim available for Finance
    ...                processing, without the HoD having to open each claim email.
    [Tags]    rpa-report    claims-processing    hod    pending
    Approve Honorarium Claim    ${EXT_EVAL_FULL_NAME}
