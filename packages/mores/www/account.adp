<if @css@>
	<master src="/packages/openacs-default-theme/lib/mores-master">
</if>
<else> 
	<master>
	<link rel="stylesheet" type="text/css" href="mores.css2" /> 
	<link rel="stylesheet" type="text/css" href="styles.css" />
</else>	
<style type="text/css">
	@extra_css;noquote@
</style>
<script type="text/javascript" src="includes/jquery.js"></script>

<div class="ctnAll">
	<div id="left" class="left ctnL">
		<div class="bloco  ctn1">
			<div class="ctn1top wl"></div>
			<div class="ctnLcontent wlctn">
				<h1>@account_name@ </h1>
				<h2> #mores.brief_updated_by# (@updated_at@)</h2>
				<div class="cae mdflt">#mores.select_filters#</div>
				<div class="form lista_bloco">
					<form action="account">
						 #mores.by_term#: <select id="query_id_p" name="query_id_p" <if @query_id_p@> style="color:red;font-weight:bold;" </if>>
									<option value="">TODAS</option>
									<multiple name=querys>
										<option value="@querys.query_id@" <if @querys.query_id@ eq @query_id_p@> selected="selected" </if> >@querys.query_text@ (@querys.qtd@)</option>
									</multiple>
							</select>
				
							#mores.by_network#: <select id="source_p" name="source_p" <if @source_p@> style="color:red;font-weight:bold;" </if>>
									<option value="">TODAS</option>
									<multiple name=redes>
										<option value="@redes.source@" <if @redes.source@ eq @source_p@> selected="selected" </if> >@redes.source@ (@redes.qtd@)</option>
									</multiple>
							</select> 
							
						 #mores.by_idiom#: <select id="lang_p" name="lang_p" <if @lang_p@> style="color:red;font-weight:bold;" </if>>
								<option value="todas">TODAS</option>
								<multiple name=langs>
									<option value="@langs.lang@" <if @langs.lang@ eq @lang_p@> selected="selected" </if> >@langs.lang@ (@langs.qtd@)</option>
								</multiple>
						</select> 
						<input type="hidden" id="account_id" name="account_id" value ="@account_id@"  >
						<input type="submit" value ="#mores.filter#"  >
					</form>
				</div>	
				<div class="cae mdflt">#mores.sign_in# <b>@min_date@</b> #mores.and# <b>@max_date@</b>,  <b>@qtd_total@ #mores.unique_mentions# </b>#mores.on_the social_networks_related_to_terms#.</div>	
			</div>	
			<div class="ctnbotton"></div>
		</div>
		<div class="bloco  ctn2">
			<div class="ctn2top wl">#mores.Searches# (#mores.click_here_to_open#) <if @admin_p@ eq 1> <a href="query?account_id=@account_id@"> #mores.Administrate_terms# </a> </if> </div>
			<div class="ctnLcontent wlctn">
				<ul class="tags">
					<multiple name=querys>
						<li><a target="_blank" class="link" href="monitor?query_id=@querys.query_id@&account_id=@account_id@&query_text=@querys.clear_query@" > @querys.query_text@ (@querys.qtd@) </a> </li>
					</multiple>
				</ul>
				<if @admin_geral@ eq 1> 
					<div class="cae mdflt">
						<a  href="query-ae?account_id=@account_id@" class="newtag link">#mores.insert_new_hashtag#</a>
					</div>
				</if> 
				<div class="form cae mdflt">
					<form action="monitor">
							#mores.or_quickly_see_a_term#: <input type="text" id="query_text" name="query_text" value ="">
						<input type="hidden" id="query_id" name="query_id" value =" "  >
						<input type="hidden" id="account_id" name="account_id" value ="@account_id@"  >
						<input type="submit" value ="#mores.online_monitoring#"  >
					</form>
				</div>		
			</div>	
			<div class="ctnbotton"></div>
		</div>	

		<div class="bloco ctn2">
			<div class="ctn2top wl">#mores.Graphic_of_mentions# </div>
			<div id="chartarea" class="ctnLcontent wlctn">
			
				<ul class="button_list" >
					<li style="display:inline;"><input class="selecionado button" type=button id="link_hoje" value="#mores.by_hour_today#" /> </li>
					<li style="display:inline;">  -  </li>
					<li style="display:inline;"><input class="button" type=button  id="link_hora" value="#mores.by_hour_history#"/> </li>
					<li style="display:inline;">  -  </li>
					<li style="display:inline;"><input class="button" type=button  id="link_dia" value="#mores.by_day#"/> </li>
				</ul>
				<div id="chart_dia" style="display:none;">
					<div id="mychart" class="chart" style="width: 700px; height: 500px;">
						<!-- amline script-->
				 		 <script type="text/javascript" src="/resources/mores/amline/swfobject.js"></script>
						<div id="flashcontent">
							<strong>Não foram encontrados dados ou você precisa atualizar o Flash</strong>
						</div>

						<script type="text/javascript">
							// <![CDATA[		
							var so = new SWFObject("/resources/mores/amline/amline.swf", "amline", "698", "500", "8", "#FFFFFF");
							so.addVariable("path", "/resources/mores/amline/");
							so.addVariable("settings_file", encodeURIComponent("/resources/mores/amline/amline_settings.xml"));  // you can set two or more different settings files here (separated by commas)
							so.addVariable("chart_data", encodeURIComponent(@xml;noquote@));                    // you can pass chart data as a string directly from this file
							so.write("flashcontent");
							// ]]>
						</script>
						<!-- end of amline script -->
					</div>	
				</div>	
				<div id="chart_hora" style="display:none;">
					<div id="mychart" class="chart" style="width: 700px; height: 500px;">
						<!-- amline script-->
				 		 <script type="text/javascript" src="/resources/mores/amline/swfobject.js"></script>
						<div id="flashcontent2">
							<strong>Não foram encontrados dados ou você precisa atualizar o Flash</strong>
						</div>

						<script type="text/javascript">
							// <![CDATA[		
							var so = new SWFObject("/resources/mores/amline/amline.swf", "amline", "698", "500", "8", "#FFFFFF");
							so.addVariable("path", "/resources/mores/amline/");
							so.addVariable("settings_file", encodeURIComponent("/resources/mores/amline/amline_settings.xml"));  // you can set two or more different settings files here (separated by commas)
							so.addVariable("chart_data", encodeURIComponent(@xml2;noquote@));                    // you can pass chart data as a string directly from this file
							so.write("flashcontent2");
							// ]]>
						</script>
						<!-- end of amline script -->
					</div>
				</div>		
				<div id="chart_hoje">
					<div id="mychart" class="chart" style="width: 700px; height: 500px;">
						<!-- amline script-->
				 		 <script type="text/javascript" src="/resources/mores/amline/swfobject.js"></script>
						<div id="flashcontent3">
							<strong>Não foram encontrados dados para o dia de hoje ou você precisa atualizar o Flash</strong>
						</div>

						<script type="text/javascript">
							// <![CDATA[		
							var so = new SWFObject("/resources/mores/amline/amline.swf", "amline", "698", "500", "8", "#FFFFFF");
							so.addVariable("path", "/resources/mores/amline/");
							so.addVariable("settings_file", encodeURIComponent("/resources/mores/amline/amline_settings.xml"));  // you can set two or more different settings files here (separated by commas)
							so.addVariable("chart_data", encodeURIComponent(@xml3;noquote@));   // you can pass chart data as a string directly from this file
							so.addVariable("error_loading_file", "Não foram encontrados dados para hoje");    // you can set custom "error loading file" text here
							so.write("flashcontent3");
							// ]]>
						</script>
						<!-- end of amline script -->
					</div>	<!-- mychart -->
				</div> <!-- chart_hoje -->
			
				<br>
				<br>
				<br>
				<!-- so.addVariable("chart_data", @xml;noquote@); -->
				<form id="relatorio" action="abrir-relatorio"> 	
					<input type="hidden" value="@account_id@" id="account_id" name="account_id" >
					<input type="submit" value="#mores.open_report_generator#">
				</form>	
			</div> <!-- end chart area -->
			<div class="ctnbotton"></div>
		</div> <!-- end bloco grafico -->	

	</div>

	<div id="right" class="right ctnR">

		<div class="bloco ctnR1 first">
			<div class="ctnR1top wr">#mores.feeling_analyzer#</div>
			<div class="ctnRcontent wrctn lista_bloco">
			<if @total_sent@ gt 0> 
					<!-- ampie script-->
			 		<script type="text/javascript" src="/resources/mores/ampie/swfobject.js"></script>
					<div id="flashcontent20" >
						<strong>Não foram encontrados dados ou você precisar atualizar seu flash</strong>
					</div>

					<script type="text/javascript">
						// <![CDATA[		
						var so = new SWFObject("/resources/mores/ampie/ampie.swf", "ampie", "241", "300", "8", "#FFFFFF");
						so.addVariable("path", "/resources/mores/ampie/");
						so.addVariable("settings_file", encodeURIComponent("/resources/mores/ampie/ampie_settings.xml"));                // you can set two or more different settings files here (separated by commas)
					//	so.addVariable("data_file", encodeURIComponent("ampie/ampie_data.xml"));
				
						so.addVariable("chart_data", encodeURIComponent(@xml_pizza;noquote@));                    // you can pass chart data as a string directly from this file
					//	so.addVariable("chart_settings", encodeURIComponent("data in CSV or XML format"));              // you can pass chart settings as a string directly from this file
					//	so.addVariable("additional_chart_settings", encodeURIComponent("<settings>...</settings>"));    // you can append some chart settings to the loaded ones
					//  so.addVariable("loading_settings", "LOADING SETTINGS");                                         // you can set custom "loading settings" text here
					//  so.addVariable("loading_data", "LOADING DATA");                                                 // you can set custom "loading data" text here
					//  so.addVariable("preloader_color", "#999999");
					//  so.addVariable("error_loading_file", "ERROR LOADING FILE");                                     // you can set custom "error loading file" text here
						so.write("flashcontent20");
						// ]]>
					</script>
					<!-- end of ampie script -->
			</if>
			<else>
					<p> #mores.without_analysis_of_feeling# </p>
					<if @admin_p@ eq 1> 
					#mores.click_here_to_analyze#.
						</if>
			</else>
			<if @admin_p@ eq 1> 
					<a href="sentimento-manual?@export_vars;noquote@"> #mores.mannually_analyze#</a>
			</if>
			@total_sent@ / @qtd_total@
			</div>
			<div class="ctnRbotton wr"></div>
		</div>
	<div class="bloco ctnR1">
			<div class="ctnR1top wr">Palavras mais mencionadas:</div>
			<div id="user" style="background:#fff;padding:10px; max-height: 264px;overflow-y: scroll;width: 244px;">

	Analisando as ultimas 1000 menções capturadas ...
			</div>
			<div class="ctnRbotton wr"></div>
		</div>
		<div class="bloco ctnR1">
			<div class="ctnR1top wr">#mores.Active_Users#:</div>
			<div style="background:#fff;padding:10px; max-height: 264px;overflow-y: scroll;width: 244px;">
					<table clear="all"  border="0" class="lista_bloco" cellpadding=0 cellspacing=0>	
						<multiple name=users>
							<tr><td><a target="_blank" href="http://twitter.com/@users.user_name@" ><b>@@users.user_name@ </b> </a></td>
							 <td> <a target="_blank"  href="sentimento-manual?@export_vars;noquote@&user=@users.user_name@">@users.qtd@ #mores.mentions# </a></td> </tr>
						</multiple>
					</table>
				</div>
				<div class="ctnRbotton wr"></div>
			</div>
		
		<div class="bloco ctnR1">
			<div class="ctnR1top wr">#mores.Results_by_network#:</div>
			 <div style="background:#fff;padding:10px; max-height: 264px;overflow-y: scroll;width: 244px; ">
				<table clear="all" border="0" class="lista_bloco" cellpadding=0 cellspacing=0>	
					<multiple name=redes>
						<tr><td><b>@redes.source@ </b></td> 
						<td> <a target="_blank" href="sentimento-manual?@export_vars;noquote@&source_p=@redes.source@">@redes.qtd@ #mores.mentions# </a></td> </tr>
					</multiple>
				</table>
			</div>
			<div class="ctnRbotton wr"></div>
		</div>


	</div>
</div>

		

