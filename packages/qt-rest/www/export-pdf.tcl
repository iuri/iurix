ad_page_contract {
    Exports and returns csv file to the backend
}
ns_log Notice "Running TCL script export-pdf.tcl"


#set content [ns_getcontent -as_file false]

set filename "/var/www/qonteo/oacs/packages/qt-rest/www/sample-html.html"
set fsize [file size $filename]

set fp [open $filename r]
#ns_log Notice "CONTENT \n $fp"


set fcontent [read $fp $fsize]
# ns_log Notice "CONTENT $content"



set filename [text_templates::create_pdf_from_html -html_content $fcontent]
file delete "/var/www/qonteo/oacs/packages/qt-dashboard/www/resources/temp-pdf.pdf"
file copy -- $filename "/var/www/qonteo/oacs/packages/qt-dashboard/www/resources/temp-pdf.pdf"

set fsize [file size "/var/www/qonteo/oacs/packages/qt-dashboard/www/resources/temp-pdf.pdf"]
set fp [open "/var/www/qonteo/oacs/packages/qt-dashboard/www/resources/temp-pdf.pdf" r]

# ns_return 200 application/pdf "https://dashboard.qonteo.com/primax/resources/temp-pdf.pdf"
ns_respond -status 200 \
    -type application/pdf \
    -length $fsize \
    -file $filename 
    

    
ad_script_abort





