ad_page_contract {} {
    {code ""}
} -properties {
    context:onevalue
    title:onevalue
}


set url [ad_url]
set page_url "[ad_url][ad_conn url]"
#set page_url [export_vars -base [ad_conn url]]
#set page_url "[ad_url][ad_conn url]"
#set page_url [util_get_current_url]


set title "Currency Rate"
set context [list $title]

set pretty_code $code
if {$code eq "EUR"} {
    set code "USD"
}

db_1row select_currency {
    SELECT cast(cr1.rate as numeric) AS rate,
    cast(cr1.rate as numeric)-cast(t.rate as numeric) AS diff,
    100-(cast(t.rate as numeric)*100/cast(cr1.rate as numeric)) AS percent
    FROM ix_currency_rates cr1 RIGHT OUTER JOIN (
						 SELECT rate_id, currency_code, rate
						 FROM ix_currency_rates
						 WHERE currency_code = :code
						 ORDER BY creation_date DESC LIMIT 2
						 ) AS t
    ON t.currency_code = cr1.currency_code
    WHERE cr1.rate_id <> t.rate_id    
    AND cr1.currency_code = :code
    ORDER BY creation_date DESC
    LIMIT 1

}


db_1row select_usd_rate {
    SELECT rate AS usd_rate FROM ix_currency_rates
    WHERE currency_code = 'USD'
    ORDER BY creation_date DESC LIMIT 1
}



if {$pretty_code ne "EUR"} {
    set rate [format "%.4f" [expr $rate / [expr $usd_rate]]]
    set diff [format "%.4f" [expr $diff / [expr $usd_rate]]]
    set percent [format "%.4f" [expr $percent / [expr $usd_rate]]]

} else {
    
    set rate [format "%.4f" $rate]
    set diff [format "%.4f" $diff]
    set percent [format "%.4f" $percent]
}
