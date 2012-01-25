ad_page_contract {
    main page

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-11-02
}



# FFmpeg commands

#http://www.google.com/cse?cx=partner-pub-9300639326172081%3Ad9bbzbtli15&ie=UTF-8&sa=Search&q=ffmpeg+change+resolution&hl=en#gsc.tab=0&gsc.q=ffmpeg%20change%20image%20resolution
#http://www.catswhocode.com/blog/19-ffmpeg-commands-for-all-needs

set package_id [ad_conn package_id]


set audios_url [export_vars -base "" {}]
set videos_url ""
set images_url [export_vars -base "image-commands" {}]


