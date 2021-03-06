ad_library {
    Procs for the list builder

    @author Iuri Sampaio (iuri@iurix.com)
    @creation-date 2020-08-26

}

namespace eval qt {}
namespace eval qt::list {}




ad_proc -public qt::list::write_csv {
    -name:required
} {
    Writes a CSV to the connection
} {
    # Creates the '_eval' columns and aggregates
    template::list::prepare_for_rendering -name $name

    template::list::get_reference -name $name

    set __list_name $name
    set __output {}
    set __groupby $list_properties(groupby)

    # Output header row
    set __cols [list]
    set __csv_cols [list]
    set __csv_labels [list]

    foreach __element_name $list_properties(elements) {
        template::list::element::get_reference -list_name $name -element_name $__element_name
        if {!$element_properties(hide_p)} {
            lappend __csv_cols $__element_name
            lappend __csv_labels [template::list::csv_quote $element_properties(label)]
        }
    }
    append __output "\"[join $__csv_labels "\",\""]\"\n"

    set __rowcount [template::multirow size $list_properties(multirow)]
    set __rownum 0
    # Output rows
    template::multirow foreach $list_properties(multirow) {
        set group_lastnum_p 0
        if {$__groupby ne ""} {
            if {$__rownum < $__rowcount} {
                # check if the next row's group column is the same as this one
                set next_group [template::multirow get $list_properties(multirow) [expr {$__rownum + 1}] $__groupby]
                if {[set $__groupby] ne $next_group} {
                    set group_lastnum_p 1
                }
            } else {
                set group_lastnum_p 1
            }
            incr __rownum
        }

        if {$__groupby eq "" \
                || $group_lastnum_p} {
            set __cols [list]

            foreach __element_name $__csv_cols {
                if {![string match "*___*_group" $__element_name]} {
                    template::list::element::get_reference \
                        -list_name $__list_name \
                        -element_name $__element_name \
                        -local_name __element_properties
                    if { [info exists $__element_properties(csv_col)] } {
                        lappend __cols [template::list::csv_quote [set $__element_properties(csv_col)]]
                    } else {
                        lappend __cols [template::list::csv_quote [set $__element_name]]
                    }
                } {
                    lappend __cols [template::list::csv_quote [set $__element_name]]
                }
            }
            append __output "\"[join $__cols "\",\""]\"\n"
        }
    }
    set oh [ns_conn outputheaders]
    ns_set put $oh Content-Disposition "attachment; filename=${__list_name}.csv"
    ns_return 200 "text/csv charset=iso-8859-1" $__output
}
