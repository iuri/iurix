
@doc.type;literal@
<html<if @doc.lang@ not nil> lang="@doc.lang;literal@"</if>>
<head>
    <title<if @doc.title_lang@ not nil and @doc.title_lang;literal@ ne @doc.lang;literal@> lang="@doc.title_lang;literal@"</if>>IURIX: @doc.title@</title>


<multiple name="meta">    <meta<if @meta.http_equiv@ not nil> http-equiv="@meta.http_equiv;literal@"</if><if @meta.name@ not nil> name="@meta.name;noquote@"</if><if @meta.scheme@ not nil> scheme="@meta.scheme;noquote@"</if><if @meta.lang@ not nil and @meta.lang;literal@ ne @doc.lang;literal@> lang="@meta.lang;literal@"</if> content="@meta.content@">
</multiple>

<!-- Added by iuri@iurix.com -->
<!-- Favicon features -->
<!-- creation-date: 2019-07-20 -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="msapplication-TileColor" content="#ffffff">
<meta name="msapplication-TileImage" content="/resources/images/ms-icon-144x144.png">
<meta name="theme-color" content="#ffffff">

<meta property="fb:app_id" content="107027289444477" />
<meta property="og:type" content="website" />
<meta property="og:url" content="https://iurix.com" />
<meta property="og:title" content="IURIX - Software Engeneering" />
<meta property="og:site_name" content="IURIX - Software Engineering"/>
<meta property="og:description" content="I.T. CATALIZES YOUR BUSINESS - Creating software for a purpose: to help people succeed in their business!"/>
<meta property="og:image" content="https://iurix.com/resources/images/iurixshare.png"/>
<meta property="og:image:type" content="image/png">
<meta property="og:image:width" content="200">
<meta property="og:image:height" content="202">
<meta name="twitter:image" content="https://iurix.com/resources/images/iurixshare.png" />


<!-- Added by iuri@iurix.com -->
<!-- Favicon features https://www.favicon-generator.org/  -->
<!-- creation-date: 2019-07-20 -->
<link rel="icon" type="image/png" sizes="16x16" href="/resources/images/favicon-16x16.png">
<link rel="shortcut icon" type="image/x-icon" href="/resources/images/favicon-16x16.png">

<!-- END Favicon features -->



<multiple name="link">    <link rel="@link.rel;literal@" href="@link.href@"<if @link.lang@ not nil and @link.lang;literal@ ne @doc.lang;literal@> lang="@link.lang;literal@"</if><if @link.title@ not nil> title="@link.title@"</if><if @link.type@ not nil> type="@link.type;literal@"</if><if @link.media@ not nil> media="@link.media;literal@"</if><if @link.integrity@ not nil> integrity="@link.integrity;literal@"</if><if @link.crossorigin@ not nil> crossorigin="@link.crossorigin;literal@"</if>>
</multiple>

<link rel="manifest" href="/site.manifest.json">

<multiple name="___style"> <style type="@___style.type;literal@" <if @___style.lang@ not nil and @___style.lang;literal@ ne @doc.lang;literal@> lang="@___style.lang;literal@"</if><if @___style.title@ not nil> title="@___style.title@"</if><if @___style.media@ not nil> media="@___style.media;literal@"</if><if @::__csp_nonce@ not nil> nonce="@::__csp_nonce;literal@"</if>>@___style.style;literal@
</style>
</multiple>

<comment>
   These two variables have to be set before the XinhaCore.js is loaded. To 
   enforce the order, it is put here.
</comment>
<if @::acs_blank_master__htmlareas@ defined and @::xinha_dir@ defined and @::xinha_lang@ defined>
<script type="text/javascript"<if @::__csp_nonce@ not nil> nonce="@::__csp_nonce;literal@"</if>>
_editor_url = "@::xinha_dir;literal@"; 
_editor_lang = "@::xinha_lang;literal@";
</script>
</if>



<multiple name="headscript">   <script type="@headscript.type;literal@"<if @headscript.src@ not nil> src="@headscript.src;literal@"</if><if @headscript.charset@ not nil> charset="@headscript.charset;literal@"</if><if @headscript.defer@ not nil> defer="@headscript.defer;literal@"</if><if @headscript.async@ not nil> async="@headscript.async;literal@"</if><if @headscript.integrity@ not nil> integrity="@headscript.integrity;literal@"</if><if @headscript.crossorigin@ not nil> crossorigin="@headscript.crossorigin;literal@"</if><if @::__csp_nonce@ not nil> nonce="@::__csp_nonce;literal@"</if>><if @headscript.content@ not nil>@headscript.content;noquote@</if></script>
</multiple>

<if @head@ not nil>@head;literal@</if>


<!-- Added by iuri@iurix.com -->
<!-- Google features -->
<!-- creation-date: 2019-07-20 -->
<!-- Google AdSense Snippet -->
<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<script>
  (adsbygoogle = window.adsbygoogle || []).push({
      google_ad_client: "ca-pub-9443985379428796",
      enable_page_level_ads: true
  });
</script>



<!-- Global site tag (gtag.js) - Google Analytics Snippet -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-144184532-1"></script>
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-144184532-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('set', {'user_id': '@user_id@'}); // Set the user ID using signed-in user_id.
      ga('set', 'userId', '@user_id@'); // Set the user ID using signed-in user_id.

  gtag('config', 'UA-144184532-1');
</script>

<!-- END Google features -->

</head>
<body<if @body.class@ not nil> class="@body.class;literal@"</if><if @body.id@ not nil> id="@body.id;literal@"</if>>
  @header;literal@
<slave>
  @footer;literal@
<multiple name="body_script">    <script type="@body_script.type;literal@"<if @body_script.src@ not nil> src="@body_script.src;literal@"</if><if @body_script.charset@ not nil> charset="@body_script.charset;literal@"</if><if @body_script.defer@ not nil> defer="@body_script.defer;literal@"</if><if @body_script.async@ not nil> async="@body_script.async;literal@"</if><if @body_script.integrity@ not nil> integrity="@body_script.integrity;literal@"</if><if @body_script.crossorigin@ not nil> crossorigin="@body_script.crossorigin;literal@"</if><if @::__csp_nonce@ not nil> nonce="@::__csp_nonce;literal@"</if>><if @body_script.content@ not nil>@body_script.content;literal@</if></script>
</multiple>

</body>
</html>
