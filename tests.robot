*** Settings ***

Documentation                   New test suite for CRT Assignment
Library                         QWeb
Library                         QForce
Suite Setup                     Open Browser                about:blank                 chrome
Suite Teardown                  Close All Browsers

*** Variables ***
${productName}=                 Gerald the Giraffe
${productDescription}=          Gerald the giraffe isn’t particularly spir…
${tShirtPrice}=                 (//div//p[contains(text(),'$9')])[3]
${totalAmount}=                 //span[contains(@class,'summary-fees__amount') and text()\='$9.00']
${radioButtonDevelopment}=      //input[@type\='radio' and @id\='development']
${tagPlaceholder}=              //input[@placeholder\='<tag>']
${arrowPlaceholder}=            //span[@class\="ng-arrow-wrapper"]

*** Keywords ***
Navigate to webshop page and add product to cart
    [Documentation]             This keyword is used to navigate to webshop page and add product to cart
    [Arguments]                 ${productName}              ${productDescription}       ${tShirtPrice}              ${totalAmount}

    GoTo                        ${webshopUrl}               #navigate to url
    Wait Until Keyword Succeeds                             1min                        5s                          VerifyText                  Find your spirit animal     #verify page is coorectly navigated and text is visible
    VerifyText                  ${productName}              partial_match=False         #verify required product name
    #we can verify price in two ways
    #using text and anchor
    VerifyText                  $9.00                       anchor=${productDescription}                            partial_match=false         timeout=10s                 #verify price of giraafe t shirt
    #usning xpath
    VerifyElement               ${tShirtPrice}              #verify price of giraafe t shirt
    ClickText                   ${productName}
    Wait Until Keyword Succeeds                             1min                        5s                          VerifyText                  Add to cart                 partial_match=False         #proceed to click on product to add it to the cart
    ClickText                   Add to cart
    Wait Until Keyword Succeeds                             1min                        5s                          VerifyText                  Unfortunately, this item is out of stock, remove it from the cart to continue.      #verify page is coorectly navigated and text is visible
    VerifyText                  ${productName}              partial_match=False
    #we can verify total amount in two ways
    #using text and anchor
    VerifyText                  $9.00                       anchor=Total                #verify total amount
    #usning xpath
    VerifyElement               ${totalAmount}              #verify total amount

Login to CRT
    [Documentation]             This keyword is used to login to the CRT

    GoTo                        ${copadoUrl}
    Wait Until Keyword Succeeds                             1min                        5s                          VerifyText                  Log in to Copado            partial_match=False         #Navigate to CRT login url
    VerifyText                  Continue with Salesforce    partial_matchh=False
    VerifyText                  Continue with Microsoft     partial_matchh=False
    VerifyText                  Continue with Google        partial_matchh=False
    VerifyText                  Continue with SAML          partial_matchh=False
    VerifyText                  Continue with email         partial_matchh=False
    ClickText                   Continue with email         partial_matchh=False
    Wait Until Keyword Succeeds                             1min                        5s                          VerifyText                  Forgot your password?       partial_match=False         timeout=5s                  #verify that user is navigated to next page to fill username and password
    TypeText                    Email                       ${username}
    TypeText                    Password                    ${password}
    VerifyText                  LOGIN                       partial_match=False         anchor=Back
    ClickText                   LOGIN                       partial_match=False         anchor=Back                 delay=3s
    Wait Until Keyword Succeeds                             1min                        5s                          VerifyText                  Welcome back, Priti Gopuwar!                            #verify that user is logged in to CRT and naviagted to CRT UI

Start video streaming of CRT test case
    [Documentation]             This keyword is used to start running test case in dev mode with video streaming being on
    [Arguments]                 ${radioButtonDevelopment}                               ${tagPlaceholder}           ${arrowPlaceholder}

    ClickText                   Test Jobs
    ClickText                   Run Test Job                delay=3s
    UseModal                    On
    Wait Until Keyword Succeeds                             11min                       5s                          VerifyText                  Video Recording             partial_match=False
    ClickText                   All                         partial_match=False         anchor=Video Recording      #video recording turned on
    ClickText                   Open Video Stream           partial_match=False         anchor=Stream Video         #video streaming turned on
    ClickElement                ${radioButtonDevelopment}                               #selecting development
    ClickText                   Add Execution Parameter
    TypeText                    ${tagPlaceholder}           Priti_DemoWorkshop          #typing tag value where tag is included
    ClickText                   Add Execution Parameter
    ClickElement                (${arrowPlaceholder})[3]    #excluding tag
    ClickText                   --exclude
    TypeText                    (${tagPlaceholder})[2]      Priti_CRT_Login             #typing tag value where tag is excluded
    ClickText                   Run Test Job                anchor=Cancel               #running test case in dev mode
    UseModal                    Off
    SwitchWindow                2
    ${currentUrl}               GetUrl
    Log To Console              ${currentUrl}
    Should Contain              ${currentUrl}               videostream                 #verifying video streaming is visible

*** Test Cases ***

Assignment 1: DemoWebshop_Assignment
    [Documentation]             Test Case includes verification on webshop for assignemnt
    [Tags]                      Priti_DemoWorkshop

    Navigate to webshop page and add product to cart        ${productName}              ${productDescription}       ${tShirtPrice}              ${totalAmount}

Assignment 2 & 3: Login to CRT and start video streaming of test case
    [Documentation]             Test case includes login process of CRT and verifies that video streaming is on for test case running in dev mode
    [Tags]                      Priti_CRT_Login             Priti_CRT_TestCase_VideoStream

    Login to CRT
    Start video streaming of CRT test case                  ${radioButtonDevelopment}                               ${tagPlaceholder}           ${arrowPlaceholder}

