*** Settings ***
Documentation    Page-level keywords for the Supervisor module.
...
...              Database tables driven by this role
...              ────────────────────────────────────
...              • submissions           – type: sop / thesis
...              • summary_of_proposals  – 15+ template fields (align_summary_proposals…php)
...              • supervisor_reviews    – decision + comments + signed_at  (schema.sql §11)
...              • progress_reports      – comment + sign (student_signed_at)
...              • thesis_evaluations    – grade sheet
...
...              Routes: /submissions/* and /progress-reports/*  (planned)
Resource         common.resource
Variables        ../variables/config.py
Variables        ../variables/test_data.py

*** Keywords ***
# ── Submission: Summary of Proposals ─────────────────────────────────────────

Navigate To Create SoP
    [Documentation]    Opens the Summary of Proposals creation form.
    Navigate To    /submissions/sop/create
    Wait Until Element Is Visible    id=thesis_title    timeout=${TIMEOUT}

Fill Summary Of Proposals Form
    [Documentation]    Populates all summary_of_proposals template fields.
    [Arguments]
    ...    ${thesis_type}=${SOP_THESIS_TYPE}
    ...    ${background}=${SOP_BACKGROUND}
    ...    ${problem_statement}=${SOP_PROBLEM_STATEMENT}
    ...    ${objectives}=${SOP_OBJECTIVES}
    ...    ${research_questions}=${SOP_RESEARCH_QUESTIONS}
    ...    ${literature_review}=${SOP_LITERATURE_REVIEW}
    ...    ${theoretical_framework}=${SOP_THEORETICAL_FRAMEWORK}
    ...    ${data_collection}=${SOP_DATA_COLLECTION}
    ...    ${data_analysis}=${SOP_DATA_ANALYSIS}
    ...    ${ethical_issues}=${SOP_ETHICAL_ISSUES}
    ...    ${significance}=${SOP_SIGNIFICANCE}
    Select From List By Value    id=thesis_type             ${thesis_type}
    Input Text    id=background_to_study                    ${background}
    Input Text    id=problem_statement                      ${problem_statement}
    Input Text    id=objectives                             ${objectives}
    Input Text    id=research_questions                     ${research_questions}
    Input Text    id=literature_review                      ${literature_review}
    Input Text    id=theoretical_framework                  ${theoretical_framework}
    Input Text    id=data_collection_methods                ${data_collection}
    Input Text    id=data_analysis_methods                  ${data_analysis}
    Input Text    id=ethical_issues                         ${ethical_issues}
    Input Text    id=significance                           ${significance}

Submit SoP To HoD
    [Documentation]    Submits the completed SoP form and verifies navigation.
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /submissions

# ── Submission: Thesis ────────────────────────────────────────────────────────

Navigate To Submit Thesis
    Navigate To    /submissions/thesis/create
    Wait Until Element Is Visible    css=form    timeout=${TIMEOUT}

Upload And Submit Thesis
    [Documentation]    Attaches the thesis PDF and submits on behalf of the student.
    [Arguments]    ${thesis_file_path}
    Choose File    id=thesis_document    ${thesis_file_path}
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /submissions

# ── Progress Report Review ────────────────────────────────────────────────────

Navigate To Pending Progress Reports
    Navigate To    /progress-reports/pending
    Wait Until Element Is Visible    css=table, css=[role="list"]    timeout=${TIMEOUT}

Open Progress Report For Review
    [Documentation]    Clicks the Review action for the given student's progress report.
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}
    Click Element    xpath=//tr[contains(.,'${student_name}')]//a[contains(text(),'Review') or contains(text(),'View')]
    Wait Until Element Is Visible    id=supervisor_comment, css=textarea    timeout=${TIMEOUT}

Add Supervisor Comment
    [Documentation]    Types a comment into the Supervisor comment textarea.
    [Arguments]    ${comment}=${SUPERVISOR_COMMENT}
    Input Text    id=supervisor_comment    ${comment}

Sign Progress Report
    [Documentation]    Clicks the Sign / Approve button (sets supervisor_reviews.signed_at).
    Click Element    xpath=//button[contains(text(),'Sign') or contains(text(),'Approve')]
    Wait For Inertia Navigation    /progress-reports

Comment And Sign Progress Report
    [Documentation]    Convenience: add comment then sign.
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}    ${comment}=${SUPERVISOR_COMMENT}
    Open Progress Report For Review    ${student_name}
    Add Supervisor Comment             ${comment}
    Sign Progress Report

# ── Thesis Grading ────────────────────────────────────────────────────────────

Navigate To Grade Thesis
    Navigate To    /thesis-evaluations
    Wait Until Element Is Visible    css=table    timeout=${TIMEOUT}

Grade Thesis
    [Documentation]    Selects a grade from the thesis_evaluations grade_sheet dropdown
    ...                for the specified student.
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}    ${grade}=Pass
    Click Element    xpath=//tr[contains(.,'${student_name}')]//a[contains(text(),'Grade')]
    Wait Until Element Is Visible    id=grade    timeout=${TIMEOUT}
    Select From List By Label    id=grade    ${grade}
    Input Text    id=evaluator_remarks    ${EVALUATOR_REMARKS}
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /thesis-evaluations

# ── Monitoring Student Progress ───────────────────────────────────────────────

Navigate To My Students
    Navigate To    /my-students
    Wait Until Element Is Visible    css=table, css=[role="list"]    timeout=${TIMEOUT}

View Student Progress
    [Documentation]    Opens the progress detail view for a specific student.
    [Arguments]    ${student_name}=${STUDENT_FULL_NAME}
    Click Element    xpath=//tr[contains(.,'${student_name}')]//a[contains(text(),'View') or contains(text(),'Progress')]
    Wait Until Element Is Visible    css=main    timeout=${TIMEOUT}
