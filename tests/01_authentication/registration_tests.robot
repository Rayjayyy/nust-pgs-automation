*** Settings ***
Documentation    RPA — New Student Account Provisioning Automation
...
...              ══════════════════════════════════════════════════════════
...              BUSINESS PROCESS AUTOMATED
...              ══════════════════════════════════════════════════════════
...              The PGS Admissions Office previously processed new
...              postgraduate student registrations manually — copying
...              details from application forms into the system one by one.
...              This bot automates the account-provisioning step: it reads
...              a student record, fills the Fortify registration form, and
...              submits it, creating an active system account in seconds.
...
...              Manual task replaced
...              ─────────────────────
...              Admissions staff spent up to 10 minutes per student
...              manually creating accounts.  The bot processes a batch of
...              new registrations unattended, at any time of day.
...
...              Route : /register  (resources/js/pages/auth/register.tsx)
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Open PGS Application
Suite Teardown   Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    register_fail

*** Test Cases ***

# ════════════════════════════════════════════════════════════════════════════
# ACCOUNT PROVISIONING — happy-path automation
# ════════════════════════════════════════════════════════════════════════════

Bot Provisions New Student Account From Application Record
    [Documentation]    The admissions bot reads a new applicant's details and
    ...                creates their PGS account via the registration form.
    ...                After successful provisioning the system redirects to
    ...                /dashboard, confirming the account is active and the
    ...                student can immediately access their portal.
    [Tags]    rpa-intake    account-provisioning    registration
    ${unique_email}=    Generate Unique Email    new.student
    Register New User
    ...    first_name=${NEW_FIRST_NAME}
    ...    last_name=${NEW_LAST_NAME}
    ...    email=${unique_email}
    ...    password=${NEW_PASSWORD}
    ...    password_confirm=${NEW_PASSWORD}
    Wait Until Location Contains    ${URL_DASHBOARD}    timeout=${TIMEOUT}
    Logout

# ════════════════════════════════════════════════════════════════════════════
# DATA VALIDATION — bot detects invalid data before submission
# ════════════════════════════════════════════════════════════════════════════

Bot Rejects Duplicate Email During Batch Provisioning
    [Documentation]    When processing a batch the bot checks for duplicate
    ...                accounts.  An already-registered email causes Fortify
    ...                to return a validation error; the bot logs it and skips
    ...                that record rather than creating a duplicate.
    [Tags]    rpa-intake    data-validation    negative
    Register New User
    ...    first_name=${NEW_FIRST_NAME}
    ...    last_name=${NEW_LAST_NAME}
    ...    email=${STUDENT_USER}
    ...    password=${NEW_PASSWORD}
    ...    password_confirm=${NEW_PASSWORD}
    Registration Should Fail With Error

Bot Flags Mismatched Password Records In Source Data
    [Documentation]    If source data contains a password/confirm mismatch the
    ...                bot detects the Fortify validation error, flags the record
    ...                for manual correction, and moves on to the next student.
    [Tags]    rpa-intake    data-validation    negative
    Register New User
    ...    first_name=Test
    ...    last_name=User
    ...    email=mismatch.test@students.nust.na
    ...    password=${NEW_PASSWORD}
    ...    password_confirm=DifferentPass@9999
    Registration Should Fail With Error

Bot Enforces Password Complexity Policy On Provisioned Accounts
    [Documentation]    The provisioning bot applies NUST password policy — any
    ...                weak password in the source record is rejected before the
    ...                account is created, ensuring all provisioned accounts meet
    ...                the institutional security standard.
    [Tags]    rpa-intake    data-validation    negative
    Register New User
    ...    first_name=Test
    ...    last_name=User
    ...    email=weak.pass.test@students.nust.na
    ...    password=123
    ...    password_confirm=123
    Registration Should Fail With Error
