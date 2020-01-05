<a name=top></a> 
<if @daily_p@>
<include src=../../project-manager/lib/task-calendar view=@view@ date=@date@ julian_date=@julian_date@ hide_closed_p=@hide_closed_p@ display_p=@display_p@>
</if>
<else>
<include src=../../project-manager/lib/task-week-calendar view=@view@ t_date=@t_date@ julian_date=@julian_date@ hide_closed_p=@hide_closed_p@ display_p=@display_p@ date=@date@>
</else>