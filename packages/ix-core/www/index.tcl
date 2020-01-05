ad_page_contract {}

set user_id [ad_conn user_id]


template::head::add_meta -name "viewport" -content "width=device-width, initial-scale=1, shrink-to-fit=no"
template::head::add_meta -name "description" -content "IURIX Website"
template::head::add_meta -name "author" -content "Iuri de Araujo Sampaio (iuri@iurix.com)"


#    <!-- Bootstrap core CSS -->

template::head::add_css -href "vendor/bootstrap/css/bootstrap.min.css"

#    <!-- Custom fonts for this template -->
template::head::add_css -href "vendor/fontawesome-free/css/all.min.css"
template::head::add_css -href "https://fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,700italic,800italic,400,300,600,700,800"
template::head::add_css -href "https://fonts.googleapis.com/css?family=Merriweather:400,300,300italic,400italic,700,700italic,900,900italic"
#    <!-- Plugin CSS -->
template::head::add_css -href "vendor/magnific-popup/magnific-popup.css"

#    <!-- Custom styles for this template -->

template::head::add_css -href "css/creative.min.css"



# <!-- Global site tag (gtag.js) - Google Analytics -->
# template::head::add_javascript -src "https://www.googletagmanager.com/gtag/js?id=UA-36229399-1" -order 1

# template::head::add_javascript -script "
#    window.dataLayer = window.dataLayer || [];
#    function gtag(){dataLayer.push(arguments);}
#    gtag('js', new Date());
#    
#      gtag('set', {'user_id': '$user_id'}); // Set the user ID using signed-in user_id.
#      ga('set', 'userId', '$user_id'); // Set the user ID using signed-in user_id.
#    gtag('config', 'UA-36229399-1');
#" -order 2
  
