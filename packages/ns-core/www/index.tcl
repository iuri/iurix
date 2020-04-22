ad_page_contract {}

    # Critérios de distribuiçao:
    # Quantidade - Complexidade - Competencia - Urgencia
    # Pesos :
    # 1 = 5 pontos; 2 = 15 pontos; 3 = 50 pontos; 4 = 100 pontos; 5 = 200 pontos
    # maximo de pontos por dia: 100
    
    # Contradicao:  5 = 200 enquanto o max diario é 100
    
    # qual a referencia de decisao?
    ##  Selecionar o usuario com menos pontos no dia e enviar o email?
    ## Se todos ultrapassam 100 pontos no dia?
    ### deve-se aguardar o proximo dia?





set mail_id [db_string select_mail_id {
    SELECT mail_id FROM iurix_mails WHERE mail_id = 918
} -default 0]


#ns_core::email::scan_email -mail_id $mail_id


template::head::add_javascript -src "https://www.gstatic.com/charts/loader.js"


#security::csp::require style-src maxcdn.bootstrapcdn.com
#security::csp::require script-src maxcdn.bootstrapcdn.com

#security::csp::require font-src 'self'
#security::csp::require font-src maxcdn.bootstrapcdn.com




#template::head::add_meta -http_equiv "Content-Security-Policy" -content "default-src 'self' gap:; script-src 'self' data: https://ssl.gstatic.com 'unsafe-eval'; object-src *; style-src 'self' data: 'unsafe-inline'; img-src 'self' data:; media-src 'self' data:; font-src 'self' data:; connect-src *"
#template::head::add_javascript -src "https://www.gstatic.com/charts/loader.js" -order 1
#template::head::add_javascript -src "/resources/ns-core/js/charts.js" -order 2




# References
# https://www.w3schools.com/howto/howto_google_charts.asp
# https://www.w3schools.com/howto/tryit.asp?filename=tryhow_google_pie_chart
# https://developers.google.com/chart/interactive/docs/gallery/piechart#donut




