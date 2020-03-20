ad_page_contract {} {
    file1:trim,optional
    file1.tmpfile:tmpfile,optional
    file2:trim,optional
    file2.tmpfile:tmpfile,optional
} -validate {
    max_size1 -requires {file_old} {
	set n_bytes [file size ${file_old.tmpfile}]
	if { $n_bytes > 1024} {
	    ad_complain "Your file is larger than the maximum file size allowed on this system ([util_commify_number $max_bytes] bytes)"
	    ad_script_abort
	}
    }
    max_size2 -requires {file_new} {
	set n_bytes [file size ${file_new.tmpfile}]
	if { $n_bytes > 1024} {
	    ad_complain "Your file is larger than the maximum file size allowed on this system ([util_commify_number 1024] bytes)"
	    ad_script_abort
	}
    }
    empty_size1 -requires {file_old} {
	set n_bytes [file size ${file_old.tmpfile}]
	if { $n_bytes eq 0} {
	    ad_complain "Your file is empty!"
	}
    }
    empty_size2 -requires {file_new} {
	set n_bytes [file size ${file_new.tmpfile}]
	if { $n_bytes eq 0} {
	    ad_complain "Your file is empty!"
	}
    }
}

auth::require_login

set l_months [list "zero" "Janeiro" "Fevereiro" "Março" "Abril" "Maio" "Junho" "Julho" "Agosto" "Setembro" "Outubro" "Novembro" "Dezembro" ]
set curr_month [db_string select_current_month {
    SELECT EXTRACT(month FROM now()) FROM dual 
} -default ""]

set curr_month [lindex $l_months $curr_month]
set curr_year [db_string select_current_year {
    SELECT EXTRACT(year FROM now()) FROM dual 
} -default ""]

ad_form -name new_rate -form {
    {inform:text(inform) {label ""}  {value "<h1>Taxa de Juros Selic Mensal<h1/>"}}
    {inform_date:text(inform) {label ""}  {value "<h4>Vigência do mês $curr_month de $curr_year<h4/>"} }
    {rate:text {label "Taxa de Juros Selic"} {html "size 30"}
    {help_text "Insira a aliquote SELIC correspondente ao mês atual indicado acima."}}
} -on_submit {

} -after_submit {

    
    ad_script_abort    
}

ad_form -name filediff -html {enctype multipart/form-data} -form {
    {inform:text(inform) {label ""}  {value "<h1>Tabelas Taxa de Juros Selic<h1/>"}}
    {file1:file {label "Taxa de Juros Selic"} {html "size 30"}}
    {file2:file {label "Taxa de Juros Selic Acumulada Mensalmente"} {html "size 30"}}    
} -on_submit {

    # to get old_file's filesize
    set filesize1 [file size ${file1.tmpfile}]
    # to get new_file's filesize is greater than 0 
    set filesize2 [file size ${file2.tmpfile}]
    
    # to open files and assign them address to their respective variables: f1 and f2. Given read permissions only!
    set f1 [open ${file1.tmpfile} r]
    set f2 [open ${file2.tmpfile} r]
    
    # to read file streams and assign their content to new variables: lines1 and lines2
    set lines1 [split [read $f1] "\n"]
    set lines2 [split [read $f2] "\n"]

    ix_selic::rates::add -lines $lines1 -type 0
    ix_selic::rates::add -lines $lines2 -type 1
    
    
    # Releasing memory, delete and unset files and variables
    file delete -- ${file1.tmpfile}
    file delete -- ${file2.tmpfile}
   # unset f1 unset f2 unset lines1 unset lines2
    # once execution is completed, finish it

    ad_returnredirect [ad_conn url]
    ad_script_abort


}

    
    


