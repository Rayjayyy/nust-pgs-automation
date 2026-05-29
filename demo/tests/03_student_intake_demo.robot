*** Settings ***
Documentation       DEMO Suite 3 — Student Application Intake & Progress Reporting
...
...                 What this shows:
...                   • Bot verifies student portal is accessible (system health check)
...                   • Bot validates application data completeness using Python logic
...                   • Bot auto-fills and submits a 7-field postgraduate application
...                   • Bot auto-fills and submits a 5-field semester progress report
...                   • Routing and confirmation status verified at each step
...
...                 Manual effort replaced:
...                   "Committee review sessions with paper application packs,
...                    students queuing at the PG office to hand in forms."
...                   — This bot processes applications automatically, 24/7.

Metadata            Suite         Demo — Student Intake
Metadata            Version       1.0
Metadata            Author        ASD810S Assignment II

Library             SeleniumLibrary
Library             OperatingSystem
Library             Collections
Library             ${CURDIR}/../libraries/CustomLibrary.py
Resource            ${CURDIR}/../resources/demo_common.robot

Suite Setup         Open Demo Browser
Suite Teardown      Close All Browsers
Test Setup          Go To Page    ${BASE_URL}/login
Test Teardown       Run Keyword If Test Failed    Capture Page Screenshot    EMBED

*** Variables ***
${STUDENT_FIRST}        Tendai
${STUDENT_LAST}         Moyo
${STUDENT_EMAIL}        tendai.moyo@students.nust.na
${STUDENT_PASSWORD}     password
${PROGRAM}              PhD Information Systems

*** Test Cases ***

# =============================================================================
# TC-DEMO-STU-001 — Bot Verifies Student Portal Is Accessible
# =============================================================================
TC-DEMO-STU-001 Bot Verifies Student Portal Is Active And Student Can Authenticate
    [Documentation]    The bot authenticates as the student service account and confirms
    ...                the student portal is active — a pre-run health check that prevents
    ...                the batch provisioning job from running against a down system.
    [Tags]    demo    student    auth    rpa-auth

    Log    [BOT] ---    level=INFO
    Log    [BOT] TC-DEMO-STU-001 Starting                                      level=INFO
    Log    [BOT] Health check: can student service account access portal?      level=INFO
    Log    [BOT] ---    level=INFO

    # Authenticate with student service account
    Go To Page    ${BASE_URL}/login
    Wait Until Element Is Visible    id=username    timeout=10
    Input Text        id=username    ${STUDENT_EMAIL}
    Input Password    id=password    ${STUDENT_PASSWORD}
    Click Button      id=login-button

    # Verify role — confirms credentials are valid
    Wait Until Element Contains    id=user-role-badge    Student    timeout=10
    Log    [BOT] Student account authenticated successfully    level=INFO

    # Confirm student portal is reachable
    Go To Page    ${STUDENT_PORTAL}
    Wait Until Page Contains    Student Portal    timeout=10
    Log    [BOT] Student portal is active and accessible    level=INFO
    Log    [REPLACED] IT staff manually checking system availability before batch runs    level=INFO


# =============================================================================
# TC-DEMO-STU-002 — Bot Validates Application Data Before Submission
# =============================================================================
TC-DEMO-STU-002 Bot Validates Application Data Completeness Before Submission
    [Documentation]    Before submitting, the bot uses CustomLibrary.Check Submission
    ...                Completeness to verify all required application fields are present
    ...                and non-empty. Missing fields are flagged and logged — preventing
    ...                incomplete applications from entering the review queue.
    [Tags]    demo    student    validation    rpa-intake

    Log    [BOT] ---    level=INFO
    Log    [BOT] TC-DEMO-STU-002 Starting                                      level=INFO
    Log    [BOT] Task: validate application data completeness                  level=INFO
    Log    [BOT] ---    level=INFO

    # Define required fields for a PG application
    ${required}=    Create List
    ...    first_name
    ...    last_name
    ...    email
    ...    program
    ...    research_area
    ...    supervisor_id
    ...    personal_statement

    # Test Case A: Complete application (all fields present)
    ${complete_data}=    Create Dictionary
    ...    first_name=Tendai
    ...    last_name=Moyo
    ...    email=tendai.moyo@students.nust.na
    ...    program=PhD Information Systems
    ...    research_area=Machine Learning in Healthcare
    ...    supervisor_id=SUP001
    ...    personal_statement=I am highly motivated to pursue doctoral research in AI...

    ${result_ok}=    Check Submission Completeness
    ...    required_fields=${required}
    ...    submitted_data=${complete_data}

    Log    [BOT] ---    level=INFO
    Should Be True    ${result_ok}[complete]    Application should be complete

    # Test Case B: Incomplete application (missing research_area and supervisor)
    ${incomplete_data}=    Create Dictionary
    ...    first_name=Amara
    ...    last_name=Nkosi
    ...    email=a.nkosi@students.nust.na
    ...    program=MSc Computer Science
    ...    research_area=
    ...    supervisor_id=
    ...    personal_statement=

    ${result_fail}=    Check Submission Completeness
    ...    required_fields=${required}
    ...    submitted_data=${incomplete_data}

    Log    [BOT] ---    level=INFO
    Log    [BOT] Missing fields: ${result_fail}[missing_fields]    level=INFO
    Log    [BOT] Empty fields: ${result_fail}[empty_fields]    level=INFO
    Should Not Be True    ${result_fail}[complete]    Application should be flagged incomplete

    Log    [BOT] ---    level=INFO
    Log    [REPLACED] Manual checking of paper applications for missing fields    level=INFO


# =============================================================================
# TC-DEMO-STU-003 — Bot Auto-Fills and Submits Postgraduate Application
# =============================================================================
TC-DEMO-STU-003 Bot Auto-Fills And Submits Postgraduate Application
    [Documentation]    The bot auto-populates all fields of the postgraduate application
    ...                form using the student's pre-validated data record, submits the form,
    ...                and verifies the system issues a reference number — replacing the
    ...                student queuing at the PG office or filling paper forms.
    [Tags]    demo    student    application    rpa-intake

    Log    [BOT] ---    level=INFO
    Log    [BOT] TC-DEMO-STU-003 Starting                                      level=INFO
    Log    [BOT] Task: auto-fill and submit PG application form                level=INFO
    Log    [BOT] ---    level=INFO

    # Authenticate
    Login As Student

    # Navigate to application form
    Go To Page    ${STUDENT_PORTAL}/application/new
    Wait Until Element Is Visible    id=first-name    timeout=10
    Log    [BOT] ---    level=INFO

    # Auto-fill all form fields from student data record
    Input Text    id=first-name    ${STUDENT_FIRST}
    Log    [BOT] First name filled: ${STUDENT_FIRST}    level=INFO

    Input Text    id=last-name    ${STUDENT_LAST}
    Log    [BOT] Last name filled: ${STUDENT_LAST}    level=INFO

    Input Text    id=email    ${STUDENT_EMAIL}
    Log    [BOT] Email filled: ${STUDENT_EMAIL}    level=INFO

    Select From List By Label    id=program    PhD Information Systems
    Log    [BOT] Programme selected: PhD Information Systems    level=INFO

    Input Text    id=research-area    Machine Learning Applications in Healthcare
    Log    [BOT] Research area filled    level=INFO

    Select From List By Label    id=proposed-supervisor    Dr. J. Chikwanha
    Log    [BOT] Supervisor selected: Dr. J. Chikwanha    level=INFO

    Input Text    id=personal-statement
    ...    I am a highly motivated graduate with a BSc (Hons) in Computer Science. My research interest lies in applying machine learning techniques to improve diagnostic accuracy in resource-limited healthcare settings. I have conducted preliminary literature research and propose to develop novel NLP models for clinical text analysis. Dr. Chikwanha's research group aligns directly with my proposed work.
    Log    [BOT] Personal statement auto-populated    level=INFO

    # Submit the form
    Log    [BOT] ---    level=INFO
    Click Button    id=submit-application
    Wait Until Element Is Visible    id=application-confirmation    timeout=10

    # Verify confirmation and reference number
    Element Should Contain    id=application-confirmation    submitted successfully
    ${ref}=    Get Text    id=application-reference
    Log    [BOT] ---    level=INFO
    Should Not Be Empty    ${ref}

    # Verify workflow status
    Element Should Contain    class=workflow-status-badge    Pending

    # Send confirmation notification
    Clear Notification Log
    Send Email Notification
    ...    recipient=${STUDENT_EMAIL}
    ...    subject=Application Received — Reference ${ref}
    ...    body=Your postgraduate application has been received. Reference: ${ref}. Status: Pending FPGC Review.
    ...    notification_type=Submission Confirmation

    ${log}=    Get Notification Log
    ${nc}=    Get Length    ${log}
    Should Be True    ${nc} >= 1
    Log    [BOT] Confirmation notification sent to student    level=INFO
    Log    [REPLACED] Student queuing at PG office to hand in paper application    level=INFO


# =============================================================================
# TC-DEMO-STU-004 — Bot Auto-Populates and Submits Progress Report
# =============================================================================
TC-DEMO-STU-004 Bot Auto-Populates And Submits Semester Progress Report
    [Documentation]    The bot fills the 5-field semester progress report form using the
    ...                student's pre-stored progress data and submits it to the supervisor
    ...                review queue — replacing the 30-45 min manual form filling that
    ...                many students leave until the last day.
    [Tags]    demo    student    progress-report    rpa-report-submission

    Log    [BOT] ---    level=INFO
    Log    [BOT] TC-DEMO-STU-004 Starting                                      level=INFO
    Log    [BOT] Task: auto-fill semester progress report                      level=INFO
    Log    [BOT] ---    level=INFO

    Login As Student
    Go To Page    ${STUDENT_PORTAL}/progress-report/new
    Wait Until Element Is Visible    id=semester    timeout=10
    Log    [BOT] Progress report form loaded    level=INFO

    # Auto-fill from student's progress data record
    Select From List By Label    id=semester    Semester 1, 2026

    Input Text    id=research-progress
    ...    Completed literature review covering 47 papers in the domain of ML-based clinical decision support. Established baseline model achieving 73% diagnostic accuracy on the UCI Heart Disease dataset. Presented findings at departmental research seminar.

    Input Text    id=objectives-achieved
    ...    1. Completed systematic literature review. 2. Established experimental baseline. 3. Submitted interim report to supervisor. 4. Attended 3 research seminars.

    Input Text    id=challenges
    ...    Encountered difficulty obtaining access to anonymised clinical datasets due to ethical clearance delays. This has been escalated to the Health Ethics Committee and is expected to be resolved in Semester 2.

    Input Text    id=next-semester-plan
    ...    1. Obtain ethical clearance and acquire clinical dataset. 2. Train and evaluate proposed NLP model. 3. Write Chapter 3 (Methodology). 4. Submit conference paper draft.

    Input Text    id=consultation-hours    14
    Log    [BOT] All progress report fields populated    level=INFO

    # Submit
    Click Button    id=submit-progress-report
    Wait Until Element Is Visible    id=report-confirmation    timeout=10
    Element Should Contain    id=report-confirmation    submitted successfully
    Log    [BOT] Progress report submitted to supervisor review queue    level=INFO

    ${ref}=    Get Text    id=report-reference
    Log    [BOT] Report reference: ${ref}    level=INFO

    # Send notification to supervisor
    Clear Notification Log
    Send Email Notification
    ...    recipient=j.chikwanha@nust.na
    ...    subject=Progress Report Submitted — Tendai Moyo (Semester 1, 2026)
    ...    body=Student Tendai Moyo has submitted the Semester 1 progress report. Reference: ${ref}. Please review within 7 days.
    ...    notification_type=${NOTIF_REMINDER}

    ${log}=    Get Notification Log
    ${nc}=    Get Length    ${log}
    Should Be True    ${nc} >= 1
    Log    [BOT] Supervisor notified of progress report submission    level=INFO
    Log    [REPLACED] Student manually writing and emailing report to supervisor    level=INFO

*** Keywords ***
# All helpers defined in demo_common.robot

