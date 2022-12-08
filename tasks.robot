*** Settings ***
Documentation       Order robots from the RobotSpareBin Industries Inc website
...                 Saves the order from HTML receipt as a PDF file
...                 Saves screenshot of the ordered robots
...                 Embeds the screenshot of the robot to the PDF receipt
...                 Creates ZIP archive of the receipts and the images

Library             RPA.Browser.Selenium    auto_close=${True}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.Windows
Library             RPA.PDF
Library             Screenshot


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open RobotSpareBin website
    Close the annoying modal
    #Fill the form for one order
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Log    ${row}
        Fill the form    ${row}
        Preview the robot
        Submit
        ${screenshot}=    Take screenshot of the robot    ${row}[Order number]
        ${pdf}=    Store receipt as PDF    ${row}[Order number]
        Log    ${pdf}
        Embed the robot screenshot to the receipt PDF file    ${pdf}    ${screenshot}
        Order another robot
    END
    #Create ZIP file of the receipts


*** Keywords ***
Open RobotSpareBin website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv
    ${data}=    Read table from CSV
    ...    orders.csv
    ...    header=true
    ...    columns=["Order number","Head","Body", "Legs","Address"]
    ...    delimiters=,
    RETURN    ${data}

Close the annoying modal
    Wait Until Page Contains Element    css:button.btn.btn-danger
    Click Button    css:button.btn.btn-danger

Fill the form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text When Element Is Visible    //input[@type="number"]    ${row}[Legs]
    Input Text    id:address    ${row}[Address]

Preview the robot
    Click Button    preview

Submit
    Wait Until Keyword Succeeds    1min    2s    Server error

Server error
    Click Button    order
    Wait Until Page Contains Element    order-another

Order another robot
    Click Button    order-another
    Close the annoying modal
    Wait Until Page Contains Element    head

Store receipt as PDF
    [Arguments]    ${row}
    Log    ${row}
    ${path}=    Convert To String    ${row}
    Log    ${path}
    Wait Until Element Is Visible    receipt
    ${receipt_html}=    Get Element Attribute    receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receiptwithscreenshot.pdf

Take screenshot of the robot
    [Arguments]    ${row}
    ${screenshot}=    RPA.Browser.Selenium.Screenshot
    ...    css:#robot-preview-image
    ...    ${OUTPUT_DIR}${/}receiptwithscreenshot.png
    RETURN    ${screenshot}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${pdf}    ${screenshot}
    Open Pdf    ${OUTPUT_DIR}${/}receiptwithscreenshot.pdf
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}receiptwithscreenshot.pdf
    ...    ${OUTPUT_DIR}${/}receiptwithscreenshot.png
    Add Files To Pdf    ${files}    summary.pdf
    Close Pdf
#Create ZIP file of the receipts

#Fill the form for one order
 #    Select From List By Value    head    2
    #    Select Radio Button    body    3
    # Input Text When Element Is Visible    //input[@type="number"]    4
    #Input Text    id:address    address 123
    #Click Button    preview
    #Wait Until Keyword Succeeds    5x    5s    Click Button When Visible    order
