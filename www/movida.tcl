ad_page_contract {}
set url "https://homologacao.movida.com.br/movida/ws3/"
set http [util::http::get -url $url]

ns_log Notice "$http"
ad_script_abort
