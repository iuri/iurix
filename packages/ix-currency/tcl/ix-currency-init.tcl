
ad_library {
    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    creation-date 2015-09-11

    Init scheduled procs

    Ref.: http://openacs.org/api-doc/proc-view?proc=ad_schedule_proc
}

ad_schedule_proc -thread t 43200 ix_currency::get_xml_ecb_currency_rates

