<if @daily_p@>
<include src=../../project-manager/lib/project-calendar view=@view@ date=@date@ julian_date=@julian_date@ hide_closed_p=@hide_closed_p@>
</if>
<else>
<include src=../../project-manager/lib/project-week-calendar view=@view@ p_date=@p_date@ julian_date=@julian_date@ hide_closed_p=@hide_closed_p@>
</else>