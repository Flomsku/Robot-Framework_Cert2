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
Library             RPA.PDF
Library             RPA.FileSystem
Library             RPA.Archive


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
    Create ZIP file of the receipts
    Cleanup temporary PDF directory


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
    Wait Until Element Is Visible    receipt
    ${receipt_html}=    Get Element Attribute    receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}temp${/}${row}.pdf
    ${pdf}=    Convert to string    ${OUTPUT_DIR}${/}temp${/}${row}.pdf
    Log    ${pdf}
    RETURN    ${pdf}

Take screenshot of the robot
    [Arguments]    ${row}
    Wait Until Element Is Visible    css:#robot-preview-image
    RPA.Browser.Selenium.Screenshot
    ...    css:#robot-preview-image
    ...    ${OUTPUT_DIR}${/}temp${/}${row}.png
    ${screenshot}=    Convert To String    ${OUTPUT_DIR}${/}temp${/}${row}.png
    Log    ${screenshot}
    RETURN    ${screenshot}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${pdf}    ${screenshot}
    Log    ${pdf}
    Open Pdf    ${pdf}
    Log    ${screenshot}
    Add Watermark Image To Pdf    ${screenshot}    ${pdf}
    Close Pdf    ${pdf}

Create ZIP file of the receipts
    Create Directory    ${OUTPUT_DIR}${/}temp
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/Receipts.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}temp    ${zip_file_name}

Cleanup temporary PDF directory
    Remove Directory    ${OUTPUT_DIR}${/}temp    True

#Fill the form for one order
 #    Select From List By Value    head    2
    #    Select Radio Button    body    3
    # Input Text When Element Is Visible    //input[@type="number"]    4
    #Input Text    id:address    address 123
    #Click Button    preview
    #Wait Until Keyword Succeeds    5x    5s    Click Button When Visible    order
