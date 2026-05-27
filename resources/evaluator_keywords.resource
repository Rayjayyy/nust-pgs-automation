*** Settings ***
Documentation    Page-level keywords for Internal and External Evaluators.
...
...              Database tables
...              ───────────────
...              Internal Evaluator
...                • evaluator_assignments   – assigned by HoD
...                • submission_evaluations  – evaluation remarks + outcome
...                • proposal_checklists / checklist_responses – Checklist items
...
...              External Evaluator
...                • thesis_evaluations          – grade_sheet + decision
...                • honorarium_claims           – 12 personal/banking fields (migration)
...                • claim_service_lines         – line-item tariff entries
...                • external_evaluator_profiles – institution, expertise, banking
Resource         common.resource
Variables        ../variables/config.py
Variables        ../variables/test_data.py

*** Keywords ***
# ════════════════════════════════════════════════════════════════════════════════
# INTERNAL EVALUATOR
# ════════════════════════════════════════════════════════════════════════════════

Navigate To Assigned Proposals
    [Documentation]    Opens the list of proposals assigned to this evaluator.
    Navigate To    /evaluations/proposals
    Wait Until Element Is Visible    css=table, css=[role="list"]    timeout=${TIMEOUT}

Open Proposal Evaluation Form
    [Documentation]    Clicks Evaluate for a specific student's proposal.
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}
    Click Element    xpath=//tr[contains(.,'${student_name}')]//a[contains(text(),'Evaluate')]
    Wait Until Element Is Visible    id=evaluation_remarks    timeout=${TIMEOUT}

Evaluate Proposal
    [Documentation]    Enters remarks and an outcome decision, then submits.
    [Arguments]    ${remarks}=${EVALUATOR_REMARKS}    ${outcome}=approved
    Input Text    id=evaluation_remarks    ${remarks}
    Select From List By Value    id=outcome    ${outcome}
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /evaluations

Navigate To Proposal Checklist
    [Documentation]    Opens the Checklist form for the assigned proposal.
    Navigate To    /evaluations/checklist
    Wait Until Element Is Visible    css=form    timeout=${TIMEOUT}

Complete And Sign Checklist
    [Documentation]    Checks all checklist_responses checkboxes and signs.
    ${checkboxes}=    Get WebElements    css=input[type="checkbox"]
    FOR    ${cb}    IN    @{checkboxes}
        Select Checkbox    ${cb}
    END
    Click Element    xpath=//button[contains(text(),'Sign') or contains(text(),'Submit')]
    Wait For Inertia Navigation    /evaluations

# ════════════════════════════════════════════════════════════════════════════════
# EXTERNAL EVALUATOR
# ════════════════════════════════════════════════════════════════════════════════

Navigate To Assigned Theses
    [Documentation]    Opens the list of theses assigned for external examination.
    Navigate To    /external-evaluations/theses
    Wait Until Element Is Visible    css=table, css=[role="list"]    timeout=${TIMEOUT}

Open Thesis Grading Form
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}
    Click Element    xpath=//tr[contains(.,'${student_name}')]//a[contains(text(),'Grade')]
    Wait Until Element Is Visible    id=grade    timeout=${TIMEOUT}

Grade Thesis As External Evaluator
    [Documentation]    Selects a grade and enters remarks in the thesis_evaluations form.
    [Arguments]    ${grade}=Pass    ${remarks}=${EVALUATOR_REMARKS}
    Select From List By Label    id=grade    ${grade}
    Input Text    id=external_remarks    ${remarks}
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /external-evaluations

# ── Honorarium Claim ──────────────────────────────────────────────────────────
# Fields map to honorarium_claims table (add_claim_details_to_honorarium_claims_table.php)

Navigate To My Claims
    Navigate To    /claims
    Wait Until Element Is Visible    css=main    timeout=${TIMEOUT}

Open New Claim Form
    Click Element    xpath=//a[contains(text(),'New Claim')] | //button[contains(text(),'New Claim')]
    Wait Until Element Is Visible    id=surname    timeout=${TIMEOUT}

Fill Honorarium Claim Form
    [Documentation]    Fills all 12 personal/banking fields from the claims migration.
    [Arguments]
    ...    ${surname}=${CLAIM_SURNAME}
    ...    ${names}=${CLAIM_NAMES}
    ...    ${programme}=${CLAIM_PROGRAMME}
    ...    ${exam_session}=${CLAIM_EXAM_SESSION}
    ...    ${exam_year}=${CLAIM_EXAM_YEAR}
    ...    ${bank_name}=${EXT_EVAL_BANK}
    ...    ${account_holder}=${EXT_EVAL_FULL_NAME}
    ...    ${account_number}=${EXT_EVAL_ACCOUNT}
    ...    ${branch_code}=${EXT_EVAL_BRANCH_CODE}
    Input Text    id=surname             ${surname}
    Input Text    id=names               ${names}
    Input Text    id=programme           ${programme}
    Input Text    id=exam_session        ${exam_session}
    Input Text    id=exam_year           ${exam_year}
    Input Text    id=bank_name           ${bank_name}
    Input Text    id=account_holder_name ${account_holder}
    Input Text    id=account_number      ${account_number}
    Input Text    id=branch_code         ${branch_code}

Submit Claim To HoD
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /claims

# ── Profile management ────────────────────────────────────────────────────────
# Maps to external_evaluator_profiles table (schema.sql §7)

Navigate To Evaluator Profile
    Navigate To    /profile/external-evaluator
    Wait Until Element Is Visible    id=institution    timeout=${TIMEOUT}

Update Evaluator Profile
    [Documentation]    Updates the external evaluator's institution and expertise fields.
    [Arguments]
    ...    ${institution}=${EXT_EVAL_INSTITUTION}
    ...    ${expertise}=${EXT_EVAL_SPECIALISATION}
    Clear Element Text    id=institution
    Input Text    id=institution    ${institution}
    Clear Element Text    id=expertise_areas
    Input Text    id=expertise_areas    ${expertise}
    Click Element    css=[data-test="update-profile-button"], css=button[type="submit"]
    Sleep    1s
