*** Settings ***
Documentation    Page-level keywords for the Faculty Postgraduate Committee (FPGC) module.
...
...              Database tables
...              ───────────────
...              • pg_applications      – review and select students
...              • application_reviews  – decision + comments + reviewed_at
...              • supervision_relationships – assign supervisor (second_co_supervisor_id)
...              • evaluator_assignments    – assign external examiner
...              • report_snapshots         – generate postgraduate activity report
Resource         common.resource
Variables        ../variables/config.py
Variables        ../variables/test_data.py

*** Keywords ***
# ── Application Review ────────────────────────────────────────────────────────

Navigate To Applications
    Navigate To    /fpgc/applications
    Wait Until Element Is Visible    css=table    timeout=${TIMEOUT}

Open Application
    [Arguments]    ${applicant_name}=${NEW_FIRST_NAME} ${NEW_LAST_NAME}
    Click Element    xpath=//tr[contains(.,'${applicant_name}')]//a[contains(text(),'View') or contains(text(),'Review')]
    Wait Until Element Is Visible    css=main    timeout=${TIMEOUT}

Review Application Details
    Page Should Contain Element    id=applicant_programme, css=[data-field="programme"]

Select Student For Supervision
    [Documentation]    Approves the application and assigns a supervisor.
    [Arguments]    ${applicant_name}=${STUDENT_FULL_NAME}    ${supervisor_name}=${SUPERVISOR_FULL_NAME}
    Open Application    ${applicant_name}
    Select From List By Label    id=supervisor_id    ${supervisor_name}
    Click Element    xpath=//button[contains(text(),'Select for Supervision')]
    Wait For Inertia Navigation    /fpgc/applications

Reject Application
    [Arguments]    ${applicant_name}=${STUDENT_FULL_NAME}    ${reason}=Does not meet minimum entry requirements
    Open Application    ${applicant_name}
    Input Text    id=rejection_reason    ${reason}
    Click Element    xpath=//button[contains(text(),'Reject')]
    Wait For Inertia Navigation    /fpgc/applications

# ── Assigning External Examiners ──────────────────────────────────────────────

Navigate To External Examiner Assignments
    Navigate To    /fpgc/external-examiners
    Wait Until Element Is Visible    css=main    timeout=${TIMEOUT}

Assign External Examiner
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}    ${examiner_name}=${EXT_EVAL_FULL_NAME}
    Click Element    xpath=//tr[contains(.,'${student_name}')]//a[contains(text(),'Assign')]
    Wait Until Element Is Visible    id=external_examiner_id    timeout=${TIMEOUT}
    # Examiners listed here are those proposed by the HoD
    Select From List By Label    id=external_examiner_id    ${examiner_name}
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /fpgc/external-examiners

# ── Report Generation ─────────────────────────────────────────────────────────
# report_snapshots table: report_code + payload + generated_by

Navigate To Reports
    Navigate To    /fpgc/reports
    Wait Until Element Is Visible    css=main    timeout=${TIMEOUT}

Generate Postgraduate Activity Report
    [Documentation]    Triggers report generation; confirms a download link appears.
    Click Element    xpath=//button[contains(text(),'Generate Report')] | //a[contains(text(),'Postgraduate Activity Report')]
    Wait Until Page Contains Element    css=a[href*="report"], css=[data-test="report-download-link"]    timeout=${TIMEOUT}

Download Report
    Click Element    css=a[href*="report"], css=[data-test="report-download-link"]
    Sleep    2s    # allow browser download to start
