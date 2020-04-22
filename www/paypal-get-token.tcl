ad_page_contract {

    Other TCL samples: https://www.example-code.com/tcl/paypal_get_oauth2_access_token.asp

    Paypal payment https://developer.paypal.com/docs/api/payments/v2/
    


}
ns_log Notice "HRLLO WORLD!"

set h [ns_set create]
ns_set update $h "Accept" "application/json"
#ns_set update $h "Accept" "application/x-www-form-urlencoded"
ns_set update $h "Accept-Language" "en_US"
ns_set update $h "Content-Type" "application/json"

ns_set update $h "Authorization" "Basic [ns_base64encode AWPWKH8kF7PmtngnMwIfjrUszGvPLtttsWQQ8FVpufXpcsED4tguctP1ikBC73jimnmcRtF580nE_Hhg:EAKxYZcZlJfH1wEzd0ovJpg2pJHzHwYdIFf45bKSi2x5FdfzPxLDa30z2cPvJLSA_Y4SKRNOk410r3Tg]"


#ns_set update $h Authorization "Basic [ns_base64encode \"AWPWKH8kF7PmtngnMwIfjrUszGvPLtttsWQQ8FVpufXpcsED4tguctP1ikBC73jimnmcRtF580nE_Hhg:EAKxYZcZlJfH1wEzd0ovJpg2pJHzHwYdIFf45bKSi2x5FdfzPxLDa30z2cPvJLSA_Y4SKRNOk410r3Tg\"]"
# ns_set update $h Authorization "Basic AWPWKH8kF7PmtngnMwIfjrUszGvPLtttsWQQ8FVpufXpcsED4tguctP1ikBC73jimnmcRtF580nE_Hhg:EAKxYZcZlJfH1wEzd0ovJpg2pJHzHwYdIFf45bKSi2x5FdfzPxLDa30z2cPvJLSA_Y4SKRNOk410r3Tg"
#ns_set update $h Authorization "sb-hnayp558863@business.example.com:H@Bad+g4"

set http [ns_http run -method POST -headers $h -body grant_type=client_credentials https://api.sandbox.paypal.com/v1/oauth2/token]
ns_log Notice "HTTP \n $http"
