*** Settings ***
Documentation       Shared variables and utility keywords for NUST PGS Demo Suite.
...                 Override BASE_URL to point at the Flask mock server.
Library             SeleniumLibrary
Library             OperatingSystem
Library             DateTime
Library             Collections
Library             ${CURDIR}/../libraries/CustomLibrary.py

*** Variables ***
# --- Mock server URL ---
${BASE_URL}         http://127.0.0.1:5000

# --- Portal shortcuts ---
${HOD_PORTAL}               ${BASE_URL}/hod
${STUDENT_PORTAL}           ${BASE_URL}/student
${EVALUATOR_PORTAL}         ${BASE_URL}/evaluator
${ADMIN_PORTAL}             ${BASE_URL}/admin

# --- File paths (relative to this resource file) ---
${REPORT_DIR}               ${CURDIR}/../reports
${DATA_DIR}                 ${CURDIR}/../data/test_data

# --- Browser settings ---
${BROWSER}          chrome
${TIMEOUT}          ${30}
${MEDIUM_WAIT}      ${5}
${SHORT_WAIT}       ${1}

# --- Workflow constants ---
${STATUS_APPROVED}          Approved
${STATUS_PENDING}           Pending
${STATUS_REJECTED}          Rejected
${NOTIF_APPROVAL}           Approval Notification
${NOTIF_REJECTION}          Rejection Notification
${NOTIF_REMINDER}           Reminder
${NOTIF_ESCALATION}         Escalation Alert
${DOC_SUMMARY_PROPOSALS}    Summary of Proposals
${DOC_THESIS}               Thesis
${DOC_PROGRESS_REPORT}      Progress Report
${REVISION_DEADLINE}        2026-06-30
${FPGC-R_ID}                fpgcr@nust.na
${HOD_ID}                   hod@nust.na

*** Keywords ***

Open Demo Browser
    [Documentation]    Opens Chrome and navigates to the mock server login page.
    Open Browser    ${BASE_URL}/login    ${BROWSER}
    Set Window Size    1280    800
    Wait For Page Load
    Log    Demo browser opened at ${BASE_URL}    level=INFO

Wait For Page Load
    [Documentation]    Waits for the page to fully render.
    Wait For Condition    return document.readyState == 'complete'    timeout=${TIMEOUT}
    Sleep    ${SHORT_WAIT}

Go To Page
    [Documentation]    Navigates to a URL and waits for page load.
    [Arguments]    ${url}
    Go To    ${url}
    Wait For Page Load

Login As HoD
    [Documentation]    Authenticates as the Head of Department service account.
    Wait Until Element Is Visible    id=username    timeout=${MEDIUM_WAIT}
    Input Text        id=username    hod@nust.na
    Input Password    id=password    password
    Click Button      id=login-button
    Wait Until Element Contains    id=user-role-badge    Head of Department    timeout=10
    Log    [BOT] Authenticated as Head of Department    level=INFO

Login As Student
    [Documentation]    Authenticates as the student service account.
    Wait Until Element Is Visible    id=username    timeout=${MEDIUM_WAIT}
    Input Text        id=username    tendai.moyo@students.nust.na
    Input Password    id=password    password
    Click Button      id=login-button
    Wait Until Element Contains    id=user-role-badge    Student    timeout=10
    Log    [BOT] Authenticated as Student    level=INFO
