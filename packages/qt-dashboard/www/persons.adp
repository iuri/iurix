<master>



<div class="container" style="width:80%">
  <div class="row">
     <div class="col-sm-12 block_title">
     	  #qt-dashboard.Persons#
     </div>
  </div>

  <div class="row">
     <div class="col-sm-4 blue_box">
     	  <div class="block1_left_box_first_text">#qt-dashboard.Today#</div>
	  <div class="block1_left_box_second_text">@today.total@</div>
	  <div class="block1_left_box_third_text">#qt-dashboard.Daily_Summary#</div>
	  <div class="block1_left_box_fourth_text">&nbsp;</div>
     </div>
     <div class="col-sm-2"></div>
     <div class="col-sm-6 double_blue_box">
       <div class="row">
         <div class="col-sm-12 block1_right_box_first_text">#qt-dashboard.Daily_Summary#</div>
       </div>
       <div class="row">
         <div class="col-sm-6">
	   <div class="block1_right_box_second_text"> @today.female@</div>
	   <div class="block1_right_box_third_text">#qt-dashboard.Women#</div>
	   <div class="block1_right_box_fourth_text">@today.female_diff@% </div>
	 </div>
	 <div class="col-sm-6">
	   <div class="block1_right_box_second_text">@today.male@</div>
	   <div class="block1_right_box_third_text">#qt-dashboard.Men#</div>
	   <div class="block1_right_box_fourth_text">@today.male_diff@%</div>
	 </div>
       </div>
     </div>
  </div>

  <div class="row">
     <div class="col-sm-12 block_title">#qt-dashboard.Daily_Hours_Summary# </div>
     <div id="daily_chart_div" style="width: 100%; height: 500px;"></div>
  </div>



  <div class="row">
     <div class="col-sm-12 block2_gray_box">
       <div class="block2_first_text">#qt-dashboard.Yesterday#</div>
       <div class="block2_second_text">@yesterday.total@</div>
       <div class="block2_third_text">#qt-dashboard.Daily_Summary#</div>
     </div>
  </div>
  <br>
  
  <div class="row block3_gray_box">
     <div class="col-sm-12">
       <div class="block3_first_text">#qt-dashboard.Daily_Summary#</div>
     </div>
     <div class="row" style="width:100%">
         <div class="col-sm-6">
	   <div class="block3_second_text">@yesterday.female@</div>
	   <div class="block3_third_text">#qt-dashboard.Women#</div>
	 </div>
	 <div class="col-sm-6">
	   <div class="block3_second_text">@yesterday.male@</div>
	   <div class="block3_third_text">#qt-dashboard.Men#</div>
	 </div>
     </div>
  </div>
  <br>

  <div class="row">
     <div class="col-sm-12 block2_gray_box">
       <div class="block4_first_text">#qt-dashboard.This_Week#</div>
       <div class="block4_second_text">@lastweek.total@</div>
       <div class="block4_third_text">#qt-dashboard.Daily_Summary#</div>
     </div>
  </div>
  <br>
  <div class="row block3_gray_box">
     <div class="col-sm-12">
       <div class="block5_first_text">#qt-dashboard.Daily_Summary#</div>
     </div>
     <div class="row" style="width:100%">
       <div class="col-sm-6">
	   <div class="block5_second_text">@lastweek.female@</div>
	   <div class="block5_third_text">#qt-dashboard.Women#</div>
       </div>
       <div class="col-sm-6">
	   <div class="block5_second_text">@lastweek.male@</div>
	   <div class="block5_third_text">#qt-dashboard.Men#</div>
       </div>
     </div>
  </div>



  <div class="row">
     <div class="col-sm-12" style="background-color: #E5E5E5;display: flex; justify-content: center; align-items: center; flex-direction: column; line-height: 4.8rem; padding: 4.5rem 0;
    box-sizing: inherit;">
    
     </div>
  </div>











  <div class="row">
     <div class="col-sm-12 block_title"> #qt-dashboard.Weekly_Summary# </div>
     <div id="weekly_chart_div" style="width: 100%; height: 500px;"></div>     
  </div>




</div>



