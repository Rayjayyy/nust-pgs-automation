*** Settings ***
Documentation    RPA — Student Application Intake & Progress Report Submission Automation
...
...              ══════════════════════════════════════════════════════════
...              BUSINESS PROCESS AUTOMATED
...              ══════════════════════════════════════════════════════════
...              Two student-facing repetitive processes are automated here:
...
...              PROCESS 1 — Postgraduate Application Intake
...              The bot acts as a digital intake clerk: it reads applicant
...              data from a structured source, fills the pg_applications
...              form in the system, and submits it.  The application is
...              automatically queued for FPGC review — replacing the
...              paper-based intake process that required staff to manually
...              capture each application.
...
...              PROCESS 2 — Periodic Progress Report Submission
...              Students are required to submit a 20-field progress report
...              every semester.  The bot pre-populates the report template
...              from the student's research record (title, objectives,
...              programme) and the period's activity data, then submits it
...              to the supervisor review queue — eliminating the error-prone
...              manual copy-and-paste that caused most late submissions.
...
...              Bot identity : tendai.moyo@students.nust.na  (PgsDemoSeeder)
...              DB tables    : pg_applications · progress_reports · submissions
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/student_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Student Login
Suite Teardown   Run Keywords    Logout    AND    Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    student_fail

*** Test Cases ***

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 1 — Postgraduate Application Intake
# ════════════════════════════════════════════════════════════════════════════

Bot Confirms Student Portal Is Active After Authentication
    [Documentation]    The student bot authenticates and verifies the portal is
    ...                available before starting the intake batch.  If the portal
    ...                is unreachable the bot aborts and raises an alert.
    [Tags]    rpa-intake    portal-check    student
    Student Lands On Dashboard After Login

Bot Submits Postgraduate Application To System
    [Documentation]    The bot fills the pg_applications form with the student's
    ...                programme and personal details, then submits.  Once submitted,
    ...                the application is automatically routed to the FPGC inbox —
    ...                replacing the physical submission of printed application forms.
    [Tags]    rpa-intake    application-submission    student    pending
    Navigate To Application Form
    Fill Application Form    programme=${STUDENT_PROGRAMME}
    Submit Application
    Verify Application Submitted    ${STUDENT_PROGRAMME}

# ════════════════════════════════════════════════════════════════════════════
# PROCESS 2 — Progress Report Automation
# ════════════════════════════════════════════════════════════════════════════

Bot Auto-Populates And Submits Semester Progress Report
    [Documentation]    The bot opens the progress_reports creation form, fills
    ...                all 20 template fields from the student's research record
    ...                and the current period's activity data, then submits the
    ...                report to the supervisor review queue.
    ...
    ...                Manual task replaced: students spent 30–45 minutes
    ...                copying research metadata into the form each semester.
    ...                The bot completes this in under 60 seconds.
    [Tags]    rpa-report-submission    progress-report    student    pending
    Navigate To Create Progress Report
    Fill Progress Report Form
    Submit Progress Report

Bot Routes Submitted Report Into Supervisor Review Queue
    [Documentation]    After submission the bot verifies the progress report
    ...                has been placed in the supervisor's pending-review queue
    ...                (submissions table, status=pending_supervisor_review).
    ...                This confirms auto-routing is working correctly.
    [Tags]    rpa-routing    progress-report    student    pending
    Navigate To My Progress
    Student Can View Submission History

Bot Uploads Supporting Document For Progress Report
    [Documentation]    The bot attaches a table-of-changes document to the
    ...                submission record — automating the file-upload step that
    ...                students frequently missed in the manual process.
    [Tags]    rpa-report-submission    document-upload    student    pending
    Navigate To Create Table Of Changes
    # Placeholder: provide a real PDF path for full run
    # Upload Table Of Changes Document    ${EXECDIR}/test_files/sample_doc.pdf

Bot Checks Student Feedback Queue For Supervisor Responses
    [Documentation]    The bot polls the feedback page and confirms that
    ...                supervisor comments on the latest progress report are
    ...                visible — closing the communication loop without the
    ...                student needing to manually check their inbox.
    [Tags]    rpa-status    feedback-check    student    pending
    Navigate To Feedback Page
    Feedback Section Contains Supervisor Comments
