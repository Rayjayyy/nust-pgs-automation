*** Settings ***
Documentation    RPA — Proposal Evaluation Queue Processing & Checklist Automation
...
...              ══════════════════════════════════════════════════════════
...              BUSINESS PROCESS AUTOMATED
...              ══════════════════════════════════════════════════════════
...              When the HoD assigns an internal evaluator to a proposal,
...              the evaluator must: open the assigned proposal, complete a
...              structured evaluation checklist, record their decision, and
...              sign off — tasks performed manually for each assignment.
...
...              PROCESS 1 — Evaluation Queue Processing
...              The bot scans the assigned-proposals queue, opens each
...              proposal, auto-fills the evaluation remarks from the
...              evaluator's assessment notes, and records the outcome.
...              The submission status automatically updates from
...              "assigned" to "evaluated" — no manual status change needed.
...
...              PROCESS 2 — Checklist Completion & Digital Signature
...              The bot completes all checklist items in the
...              proposal_checklists / checklist_responses table and applies
...              the evaluator's digital signature — replacing a paper
...              checklist that was previously scanned and filed manually.
...
...              Bot identity : e.kamati@nust.na  (PgsDemoSeeder id=102)
...              DB tables    : evaluator_assignments · submission_evaluations
...                            · proposal_checklists · checklist_responses
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/evaluator_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Internal Evaluator Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    evaluator_fail

*** Test Cases ***

Bot Confirms Evaluator Portal Access Before Processing Queue
    [Documentation]    The internal-evaluator bot authenticates and verifies
    ...                dashboard access before scanning the evaluation queue.
    [Tags]    rpa-auth    portal-check    internal-evaluator
    Location Should Contain    ${URL_DASHBOARD}

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 1 — Evaluation Queue Processing
# ════════════════════════════════════════════════════════════════════════════

Bot Scans Assigned Proposals Evaluation Queue
    [Documentation]    The bot opens /evaluations/proposals to retrieve the list
    ...                of proposals assigned to this evaluator.  The queue length
    ...                is captured in the audit log so the department can track
    ...                evaluation throughput over time.
    [Tags]    rpa-assignment    evaluation-queue    internal-evaluator    pending
    Navigate To Assigned Proposals
    Page Should Contain Element    css=table, css=[role="list"]

Bot Opens Proposal And Begins Structured Evaluation
    [Documentation]    For each proposal in the queue the bot opens the evaluation
    ...                form — confirming the id=evaluation_remarks field is ready
    ...                before entering the evaluator's structured assessment.
    [Tags]    rpa-assignment    evaluation-queue    internal-evaluator    pending
    Open Proposal Evaluation Form    ${STUDENT_FULL_NAME}
    Element Should Be Visible    id=evaluation_remarks

Bot Records Evaluation Outcome And Auto-Updates Submission Status
    [Documentation]    The bot enters evaluation remarks and records a decision
    ...                of "approved".  On submission the system automatically
    ...                updates submission_evaluations.outcome and the parent
    ...                submission's status — eliminating the manual status-update
    ...                task that previously required a separate login by the admin.
    [Tags]    rpa-status    evaluation-outcome    auto-status-update    internal-evaluator    pending
    Evaluate Proposal    ${EVALUATOR_REMARKS}    approved

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 2 — Checklist Completion & Digital Signature
# ════════════════════════════════════════════════════════════════════════════

Bot Opens Proposal Evaluation Checklist
    [Documentation]    The bot navigates to the checklist form for the assigned
    ...                proposal — a prerequisite for the automated checklist-
    ...                completion run.
    [Tags]    rpa-assignment    checklist-processing    internal-evaluator    pending
    Navigate To Proposal Checklist
    Page Should Contain Element    css=form

Bot Completes All Checklist Items And Applies Digital Signature
    [Documentation]    The bot systematically selects every checkbox in the
    ...                proposal_checklists form (checklist_responses) and applies
    ...                the evaluator's digital signature.
    ...
    ...                Manual task replaced: evaluators printed a paper checklist,
    ...                ticked boxes manually, scanned the signed document, and
    ...                emailed it to the HoD secretary.  The bot completes this
    ...                entire process in seconds and the record is immediately
    ...                available in the system.
    [Tags]    rpa-assignment    checklist-processing    digital-signature    internal-evaluator    pending
    Complete And Sign Checklist
