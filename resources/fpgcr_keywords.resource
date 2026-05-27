*** Settings ***
Documentation    Page-level keywords for the FPGC Representative (FPGC-R) module.
...
...              Database tables
...              ───────────────
...              • hdc_presentations   – item added to meeting agenda
...              • hdc_decisions       – decided_by + decision + minute_reference
...              • workflow_tasks      – FPGCR_REVIEW, HDC_REVIEW
Resource         common.resource
Variables        ../variables/config.py
Variables        ../variables/test_data.py

*** Keywords ***
# ── FPGCR Inbox ───────────────────────────────────────────────────────────────

Navigate To FPGCR Inbox
    Navigate To    /fpgcr/inbox
    Wait Until Element Is Visible    css=table    timeout=${TIMEOUT}

Open FPGCR Submission
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}
    Click Element    xpath=//tr[contains(.,'${student_name}')]//a[contains(text(),'View') or contains(text(),'Review')]
    Wait Until Element Is Visible    css=main    timeout=${TIMEOUT}

# ── Evaluating HoD Submissions ────────────────────────────────────────────────

Evaluate And Recommend To HDC
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}    ${decision}=approved
    Open FPGCR Submission    ${student_name}
    Select From List By Value    id=fpgcr_decision    ${decision}
    Input Text    id=fpgcr_remarks    Reviewed by FPGC-R. Recommended for HDC.
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /fpgcr/inbox

# ── HDC Agenda ────────────────────────────────────────────────────────────────
# hdc_presentations table

Navigate To HDC Agenda
    Navigate To    /fpgcr/hdc-agenda
    Wait Until Element Is Visible    css=main    timeout=${TIMEOUT}

Add Item To HDC Agenda
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}    ${item_type}=thesis
    Click Element    xpath=//button[contains(text(),'Add Agenda Item')]
    Wait Until Element Is Visible    id=submission_id    timeout=${TIMEOUT}
    Select From List By Label    id=item_type    ${item_type}
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /fpgcr/hdc-agenda

# ── Forwarding to HDC ─────────────────────────────────────────────────────────

Forward To HDC
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}
    Open FPGCR Submission    ${student_name}
    Click Element    xpath=//button[contains(text(),'Forward to HDC')]
    Sleep    1s

# ── Presenting at HDC ─────────────────────────────────────────────────────────

Navigate To HDC Presentations
    Navigate To    /fpgcr/presentations
    Wait Until Element Is Visible    css=table    timeout=${TIMEOUT}

Mark As Presented
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}
    Click Element    xpath=//tr[contains(.,'${student_name}')]//a[contains(text(),'Present')]
    Wait Until Element Is Visible    id=presentation_minutes    timeout=${TIMEOUT}
    Input Text    id=presentation_minutes    Item presented at HDC meeting.
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /fpgcr/presentations

# ── Recording HDC Decision ────────────────────────────────────────────────────
# hdc_decisions table: decision (decision_type enum) + minute_reference

Record HDC Decision
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}    ${decision}=approved    ${minute_ref}=HDC/2025/06/001
    Click Element    xpath=//tr[contains(.,'${student_name}')]//a[contains(text(),'Record Decision')]
    Wait Until Element Is Visible    id=hdc_decision    timeout=${TIMEOUT}
    Select From List By Value    id=hdc_decision    ${decision}
    Input Text    id=minute_reference    ${minute_ref}
    Input Text    id=hdc_comments       ${HDC_DECISION_NOTES}
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /fpgcr/presentations
