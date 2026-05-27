*** Settings ***
Documentation    Registration test suite.
...
...              Page under test : /register  (resources/js/pages/auth/register.tsx)
...
...              Element references (from source code)
...              ──────────────────────────────────────
...              id=first_name                           – first name input
...              id=last_name                            – last name input
...              id=email                                – email input
...              id=password                             – password input
...              id=password_confirmation                – confirm password input
...              css=[data-test="register-user-button"]  – Create account button
...
...              Backend : CreateNewUser.php assigns role='student' to new accounts
Resource         ../../resources/login_keywords.resource
Resource         ../../resources/common.resource
Variables        ../../variables/config.py
Variables        ../../variables/test_data.py

Suite Setup      Open PGS Application
Suite Teardown   Close PGS Application

Test Teardown    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Take Timestamped Screenshot    register_fail

*** Test Cases ***

Registration Page Renders All Required Fields
    [Documentation]    The /register page shows id=first_name, id=last_name, id=email,
    ...                id=password, id=password_confirmation and the submit button.
    [Tags]    smoke    registration    ui
    Go To    ${BASE_URL}${URL_REGISTER}
    Wait Until Element Is Visible    id=first_name    timeout=${TIMEOUT}
    Element Should Be Visible    id=last_name
    Element Should Be Visible    id=email
    Element Should Be Visible    id=password
    Element Should Be Visible    id=password_confirmation
    Element Should Be Visible    css=[data-test="register-user-button"]

Registration Page Has Link To Login
    [Documentation]    A "Log in" link is visible for users with existing accounts.
    [Tags]    smoke    registration    ui
    Go To    ${BASE_URL}${URL_REGISTER}
    Wait Until Page Contains    Log in    timeout=${TIMEOUT}

New User Can Register A Student Account
    [Documentation]    Submits the registration form with a unique email and verifies
    ...                the user is redirected to /dashboard (CreateNewUser sets role=student).
    [Tags]    smoke    registration
    ${unique_email}=    Generate Unique Email    rudo.chikara
    Fill And Submit Registration Form
    ...    first_name=Rudo
    ...    last_name=Chikara
    ...    email=${unique_email}
    ...    password=${NEW_PASSWORD}
    ...    password_confirm=${NEW_PASSWORD}
    Wait Until Location Contains    ${URL_DASHBOARD}    timeout=${TIMEOUT}
    Logout

Registration Fails When Passwords Do Not Match
    [Documentation]    Submitting mismatched password / confirm-password shows a
    ...                validation error on id=password_confirmation.
    [Tags]    regression    registration    negative
    ${unique_email}=    Generate Unique Email    nomatch
    Go To    ${BASE_URL}${URL_REGISTER}
    Wait Until Element Is Visible    id=first_name    timeout=${TIMEOUT}
    Input Text    id=first_name             Test
    Input Text    id=last_name              User
    Input Text    id=email                  ${unique_email}
    Input Text    id=password               SecurePass@001
    Input Text    id=password_confirmation  DifferentPass@999
    Click Element    css=[data-test="register-user-button"]
    Field Should Show Validation Error    password_confirmation

Registration Fails When Email Is Already Taken
    [Documentation]    Using an existing seeded email (student) triggers a unique
    ...                email validation error.
    [Tags]    regression    registration    negative
    Fill And Submit Registration Form
    ...    first_name=Duplicate
    ...    last_name=User
    ...    email=${STUDENT_USER}
    ...    password=${NEW_PASSWORD}
    ...    password_confirm=${NEW_PASSWORD}
    Field Should Show Validation Error    email

Registration Fails With Empty First Name
    [Documentation]    The first_name field is required; leaving it blank fires HTML5
    ...                constraint validation.
    [Tags]    regression    registration    negative
    Go To    ${BASE_URL}${URL_REGISTER}
    Wait Until Element Is Visible    id=first_name    timeout=${TIMEOUT}
    # Leave first_name blank
    Input Text    id=last_name              Chikara
    Input Text    id=email                  new.user@nust.na
    Input Text    id=password               ${NEW_PASSWORD}
    Input Text    id=password_confirmation  ${NEW_PASSWORD}
    Click Element    css=[data-test="register-user-button"]
    Location Should Contain    ${URL_REGISTER}

Registration Fails With Empty Email
    [Documentation]    The email field is required.
    [Tags]    regression    registration    negative
    Go To    ${BASE_URL}${URL_REGISTER}
    Wait Until Element Is Visible    id=email    timeout=${TIMEOUT}
    Input Text    id=first_name             Test
    Input Text    id=last_name              User
    Input Text    id=password               ${NEW_PASSWORD}
    Input Text    id=password_confirmation  ${NEW_PASSWORD}
    Click Element    css=[data-test="register-user-button"]
    Location Should Contain    ${URL_REGISTER}
