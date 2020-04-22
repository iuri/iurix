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
