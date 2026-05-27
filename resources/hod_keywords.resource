*** Settings ***
Documentation    Page-level keywords for the Head of Department (HoD) module.
...
...              Database tables
...              ───────────────
...              • evaluator_assignments         – assign internal evaluators
...              • external_examiner_proposals   – propose external evaluators
...              • hod_decisions                 – decision + conditions + signed_at
...              • honorarium_claims             – approve claim
...              • workflow_tasks                – SUPERVISOR_REVIEW, HOD_REVIEW tasks
Resource         common.resource
Variables        ../variables/config.py
Variables        ../variables/test_data.py

*** Keywords ***
# ── Submission Inbox ──────────────────────────────────────────────────────────

Navigate To HoD Inbox
    Navigate To    /hod/inbox
    Wait Until Element Is Visible    css=table    timeout=${TIMEOUT}

Open Submission
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}
    Click Element    xpath=//tr[contains(.,'${student_name}')]//a[contains(text(),'View') or contains(text(),'Review')]
    Wait Until Element Is Visible    css=main    timeout=${TIMEOUT}

# ── Assigning Internal Evaluators ─────────────────────────────────────────────
# evaluator_assignments table: evaluator_id + assigned_by + deadline + status

Navigate To Evaluator Assignments
    Navigate To    /hod/evaluator-assignments
    Wait Until Element Is Visible    css=main    timeout=${TIMEOUT}

Assign Internal Evaluator
    [Documentation]    Assigns an internal evaluator to a student proposal.
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}    ${evaluator_name}=${INT_EVAL_FULL_NAME}
    Open Submission    ${student_name}
    Select From List By Label    id=internal_evaluator    ${evaluator_name}
    Input Text    id=deadline    2026-08-01
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /hod

# ── Evaluating Supervisor Submissions ─────────────────────────────────────────
# hod_decisions table: decision + conditions + comments + signed_at

Record HoD Decision
    [Documentation]    Records the HoD's decision on a Supervisor submission.
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}    ${decision}=approved
    Open Submission    ${student_name}
    Select From List By Value    id=decision    ${decision}
    Input Text    id=comments    Reviewed by Head of Department.
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /hod/inbox

# ── Forwarding to FPGC-R ──────────────────────────────────────────────────────

Forward To FPGCR
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}
    Open Submission    ${student_name}
    Click Element    xpath=//button[contains(text(),'Forward to FPGC-R')]
    Wait For Inertia Navigation    /hod/inbox

# ── Proposing External Evaluators ─────────────────────────────────────────────
# external_examiner_proposals table

Navigate To Propose External Evaluators
    Navigate To    /hod/propose-evaluators
    Wait Until Element Is Visible    css=form    timeout=${TIMEOUT}

Propose External Evaluator
    [Arguments]
    ...    ${student_name}=${STUDENT_FULL_NAME}
    ...    ${evaluator_name}=${EXT_EVAL_FULL_NAME}
    ...    ${institution}=${EXT_EVAL_INSTITUTION}
    ...    ${email}=${EXT_EVAL_EMAIL}
    Open Submission    ${student_name}
    Input Text    id=proposed_evaluator_name         ${evaluator_name}
    Input Text    id=proposed_evaluator_institution  ${institution}
    Input Text    id=proposed_evaluator_email        ${email}
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /hod

# ── Honorarium Claims ─────────────────────────────────────────────────────────

Navigate To Claims Management
    Navigate To    /hod/claims
    Wait Until Element Is Visible    css=table    timeout=${TIMEOUT}

Approve Honorarium Claim
    [Arguments]    ${evaluator_name}=${EXT_EVAL_FULL_NAME}
    Click Element    xpath=//tr[contains(.,'${evaluator_name}')]//button[contains(text(),'Approve')]
    Sleep    1s
    Page Should Contain    approved
