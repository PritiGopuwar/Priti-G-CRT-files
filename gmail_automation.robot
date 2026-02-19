*** Settings ***
Library                         QWeb
Library                         ${CURDIR}/GmailLibrary.py
Suite Setup                     Open Browser                about:blank                 chrome
Suite Teardown                  Disconnect From Gmail

*** Variables ***
${testUrl_1}=                   https://qentinelqi.github.io/shop/
${testUrl_2}=                   https://github.com/login
${testUrl_3}=                   https://github.com/explore
${emailSubject}=                Assignment 4- Send email and open all URLs

*** Keywords ***

Send email and test single URL
    [Documentation]             This keyword is used to verify thzt email is sent via gmail and single URL is opened which is included in body
    [Arguments]                 ${emailSubject}             ${testUrl_1}

    ${email_body}=              Set Variable                Hello!\n\nPlease visit this link: ${testUrl_1}\n\nThis is an automated test email.
    Send Email                  ${gmailUsername}            ${emailSubject}             ${email_body}
    Log To Console              Email sent successfully to ${gmailUsername}
    Sleep                       20s

    Log To Console              Searching for email with subject: ${emailSubject}
    Select Mailbox              INBOX
    ${latest_email_id}=         Get Latest Email Id         SUBJECT "${emailSubject}"
    Should Not Be Empty         ${latest_email_id}          msg=No emails found with subject: ${emailSubject}
    ${subject}=                 Get Email Subject           ${latest_email_id}
    Should Be Equal             ${emailSubject}             ${subject}
    Log To Console              Found email: ${subject}
    ${url}=                     Get First Url From Email    ${latest_email_id}
    Go To                       ${url}
    Sleep                       3s
    ${current_url}=             Get Url
    Should Be Equal             ${current_url}              ${testUrl_1}

Send email and test multiple URLs
    [Documentation]             This keyword is used to verify thzt email is sent via gmail and multiple URLs are opened which are included in body
    [Arguments]                 ${emailSubject}             ${testUrl_1}                ${testUrl_2}     ${testUrl_3}

    ${email_body}=              Catenate
    ...                         Check out these links:
    ...                         1. ${testUrl_1}
    ...                         2. ${testUrl_2}
    ...                         3. ${testUrl_3}
    Send Email                  ${gmailUsername}            ${emailSubject}             ${email_body}
    Sleep                       20s
    Select Mailbox              INBOX
    ${latest_email_id}=         Get Latest Email Id         SUBJECT "${emailSubject}"
    ${all_urls}=                Extract Urls From Email     ${latest_email_id}
    Log To Console              Found URLs: ${all_urls}
    FOR                         ${url}                      IN                          @{all_urls}
        Log To Console          Opening: ${url}
        Go To                   ${url}
        ${current_url}          GetUrl
        Should Be Equal         ${current_url}              ${url}
    END
    Log To Console              Navigated to all URLs

*** Test Cases ***
Verify Gmail Email Reception
    [Documentation]             Example test to send email and open all URLs from received emails
    [Tags]                      Priti_EmailAutomation

    Connect To Gmail            ${gmailUsername}            ${gmailPassword}
    Send email and test single URL                          ${emailSubject}             ${testUrl_1}
    Send email and test multiple URLs                       ${emailSubject}             ${testUrl_1}     ${testUrl_2}    ${testUrl_3}
