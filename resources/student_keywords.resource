*** Settings ***
Documentation    Page-level keywords for the Student module of the NUST PGS system.
...
...              Implemented pages  (current version)
...              ────────────────────────────────────
...              /dashboard  – post-login landing (placeholder UI)
...
...              Planned pages  (business schema in place, routes pending)
...              ──────────────────────────────────────────────────────
...              The database schema (schema.sql / migrations) fully defines the
...              following tables that drive student workflows:
...                • pg_applications       – postgraduate placement applications
...                • submissions           – progress_report / sop / thesis
...                • progress_reports      – detailed progress report form
...                • document_versions     – uploaded file metadata
...                • notifications         – in-app notifications
...
...              Keywords below are written against the expected UI paths.
...              When those pages ship, replace the TODO comments with real
...              element locators from the rendered HTML.
Resource         common.resource
Variables        ../variables/config.py
Variables        ../variables/test_data.py

*** Keywords ***
# ── Dashboard ─────────────────────────────────────────────────────────────────

Student Lands On Dashboard After Login
    [Documentation]    After a successful login the URL must contain /dashboard.
    Location Should Contain    ${URL_DASHBOARD}
    Wait Until Page Contains Element    css=main    timeout=${TIMEOUT}

# ── Postgraduate Application ─────────────────────────────────────────────────
# Route: /applications/create  (planned – not yet in web.php)

Navigate To Application Form
    [Documentation]    Opens the postgraduate placement application form.
    Navigate To    /applications/create
    # TODO: replace with real element id once the page ships
    Wait Until Element Is Visible    css=form    timeout=${TIMEOUT}

Fill Application Form
    [Documentation]    Populates the pg_applications form fields.
    [Arguments]
    ...    ${programme}=${STUDENT_PROGRAMME}
    # TODO: map to real input ids from the rendered page
    Input Text    id=programme    ${programme}

Submit Application
    [Documentation]    Submits the application and waits for a confirmation.
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /applications

Verify Application Submitted
    [Documentation]    Checks the application list page contains the programme name.
    [Arguments]    ${programme}=${STUDENT_PROGRAMME}
    Page Should Contain    ${programme}

# ── Progress Report ───────────────────────────────────────────────────────────
# Route: /submissions/progress-reports/create  (planned)
# DB   : progress_reports table (schema.sql + align_forms_with_templates.php)

Navigate To Create Progress Report
    Navigate To    /submissions/progress-reports/create
    Wait Until Element Is Visible    id=research_title    timeout=${TIMEOUT}

Fill Progress Report Form
    [Documentation]    Fills all fields of the Progress Report template.
    [Arguments]
    ...    ${research_title}=${PR_RESEARCH_TITLE}
    ...    ${year}=${PR_YEAR_UNDER_REVIEW}
    ...    ${semester}=${PR_SEMESTER_END}
    ...    ${degree_label}=${PR_DEGREE_LABEL}
    ...    ${problem_statement}=${PR_PROBLEM_STATEMENT}
    ...    ${objectives}=${PR_RESEARCH_OBJECTIVES}
    ...    ${activities_completed}=${PR_ACTIVITIES_COMPLETED}
    ...    ${outputs_delivered}=${PR_OUTPUTS_DELIVERED}
    ...    ${on_schedule}=${PR_ON_SCHEDULE}
    ...    ${on_budget}=${PR_ON_BUDGET}
    ...    ${on_target}=${PR_ON_TARGET}
    ...    ${challenges}=${PR_CHALLENGES}
    ...    ${student_comments}=${PR_STUDENT_COMMENTS}
    # TODO: id attributes → replace when page ships
    Input Text    id=research_title         ${research_title}
    Input Text    id=year_under_review       ${year}
    Input Text    id=semester_end            ${semester}
    Input Text    id=degree_label            ${degree_label}
    Input Text    id=problem_statement       ${problem_statement}
    Input Text    id=research_objectives     ${objectives}
    Input Text    id=activities_completed    ${activities_completed}
    Input Text    id=outputs_delivered       ${outputs_delivered}
    Select From List By Label    id=on_schedule    ${on_schedule}
    Select From List By Label    id=on_budget      ${on_budget}
    Select From List By Label    id=on_target      ${on_target}
    Input Text    id=challenges              ${challenges}
    Input Text    id=student_comments        ${student_comments}

Submit Progress Report
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /submissions

# ── Table of Changes ──────────────────────────────────────────────────────────
# Route: /submissions/table-of-changes/create  (planned)

Navigate To Create Table Of Changes
    Navigate To    /submissions/table-of-changes/create
    Wait Until Element Is Visible    css=form    timeout=${TIMEOUT}

Upload Table Of Changes Document
    [Documentation]    Attaches a PDF to the table-of-changes upload field.
    [Arguments]    ${file_path}
    # TODO: replace id=file_upload with the real input id
    Choose File    id=file_upload    ${file_path}
    Click Element    css=button[type="submit"]
    Wait For Inertia Navigation    /submissions

# ── Checking Progress ─────────────────────────────────────────────────────────
# Route: /my-progress  (planned)

Navigate To My Progress
    Navigate To    /my-progress
    Wait Until Element Is Visible    css=main    timeout=${TIMEOUT}

Student Can View Submission History
    Page Should Contain Element    css=table, css=[role="list"]

# ── Checking Feedback ─────────────────────────────────────────────────────────
# Route: /feedback  (planned)

Navigate To Feedback Page
    Navigate To    /feedback
    Wait Until Element Is Visible    css=main    timeout=${TIMEOUT}

Feedback Section Contains Supervisor Comments
    [Documentation]    Asserts that Supervisor-authored feedback is visible.
    Page Should Contain Element    css=[data-role="supervisor-feedback"], xpath=//*[contains(@class,'feedback') and contains(.,'Supervisor')]

Feedback Section Contains HDC Comments
    [Documentation]    Asserts that HDC feedback is visible.
    Page Should Contain Element    css=[data-role="hdc-feedback"], xpath=//*[contains(@class,'feedback') and contains(.,'HDC')]
