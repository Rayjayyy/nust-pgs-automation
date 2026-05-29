*** Variables ***
# =============================================================================
# NUST Postgraduate Digital System - Global Variables
# Scope: Cross-module shared variables
# Author: ASD810S Assignment II
# Date: 2026-05-28
# =============================================================================

# --- Environment Configuration ---
${ENV}                  dev
${BASE_URL}             https://pg-system-dev.nust.na
${BROWSER}              chrome
${HEADLESS}             ${FALSE}
${TIMEOUT}              ${30}
${IMPLICIT_WAIT}        ${10}
${WINDOW_WIDTH}         ${1920}
${WINDOW_HEIGHT}        ${1080}

# --- System Paths ---
${LOGIN_URL}            ${BASE_URL}/login
${DASHBOARD_URL}        ${BASE_URL}/dashboard
${STUDENT_PORTAL}       ${BASE_URL}/student
${SUPERVISOR_PORTAL}    ${BASE_URL}/supervisor
${HOD_PORTAL}           ${BASE_URL}/hod
${FPGC_PORTAL}          ${BASE_URL}/fpgc
${EVALUATOR_PORTAL}     ${BASE_URL}/evaluator

# --- File Paths ---
${DATA_DIR}             ${CURDIR}/../data/test_data
${REPORT_DIR}           ${CURDIR}/../reports
${SCREENSHOT_DIR}       ${REPORT_DIR}/screenshots
${LOG_DIR}              ${REPORT_DIR}/logs

# --- Timeouts & Intervals ---
${SHORT_WAIT}           ${2}
${MEDIUM_WAIT}          ${5}
${LONG_WAIT}            ${10}
${RETRY_INTERVAL}       ${1}
${MAX_RETRIES}          ${3}

# --- Workflow Thresholds ---
${REMINDER_DAYS}        ${3}
${ESCALATION_DAYS}      ${7}
${REPORT_GENERATION_DAY}    Friday
${REPORT_GENERATION_TIME}   17:00

# --- Status Constants ---
${STATUS_PENDING}       Pending
${STATUS_IN_PROGRESS}   In Progress
${STATUS_UNDER_REVIEW}  Under Review
${STATUS_APPROVED}      Approved
${STATUS_REJECTED}      Rejected
${STATUS_COMPLETED}     Completed
${STATUS_OVERDUE}       Overdue

# --- Document Types ---
${DOC_PROGRESS_REPORT}      Progress Report
${DOC_TABLE_OF_CHANGES}     Table of Changes
${DOC_SUMMARY_PROPOSALS}    Summary of Proposals
${DOC_THESIS}               Thesis
${DOC_CHECKLIST}            Checklist
${DOC_CLAIM}                Honorarium Claim

# --- Notification Templates ---
${NOTIF_CONFIRMATION}   Submission Confirmation
${NOTIF_REMINDER}       Reminder
${NOTIF_ESCALATION}     Escalation Alert
${NOTIF_APPROVAL}       Approval Notification
${NOTIF_REJECTION}      Rejection Notification

# --- Test Data ---
${TEST_STUDENT_ID}      PG2026001
${TEST_SUPERVISOR_ID}   SUP2026001
${TEST_HOD_ID}          HOD2026001
${TEST_EVALUATOR_ID}    EVA2026001
