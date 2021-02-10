ad_page_contract {}


ad_form -name upload-csv  -html { enctype multipart/form-data } -form {
    file_id:key
    {upload_file:file {label \#file-storage.Upload_a_file\#} {html "size 30"}}
}


