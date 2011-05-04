# packages/documents/tcl/install-procs.tcl

ad_library {

    Documents Install Library

    callback implementations for videos
    
    @author iuri sampaio (iuri.sampaio@gmail.com)
    @creation-date 2010-06-09
}


namespace eval documents::install {}



ad_proc -private documents::install::add_categories {
    {-package_id ""}
} {
    a callback install that adds standard tree, categories ans sub-categories related to documents 
} {
    
    #create category tree
    set tree_id [category_tree::add -name documents]
    
    set parent_id [category::add -tree_id $tree_id -parent_id [db_null] -name "Tipo" -description "Tipo de Documento"]
    set art_id [category::add -tree_id $tree_id -parent_id $parent_id -name "Artigos" -description "Artigos"]
    set doc_id [category::add -tree_id $tree_id -parent_id $parent_id -name "Documentação" -description "Documentação"]
    set leg_id [category::add -tree_id $tree_id -parent_id $parent_id -name "Legislação" -description "Legislação"]

    category::add -tree_id $tree_id -parent_id $art_id -name "Livre" -description "Livre"
    category::add -tree_id $tree_id -parent_id $art_id -name "Científico" -description "Científico"
    category::add -tree_id $tree_id -parent_id $art_id -name "Institucional" -description "Institucional"
    category::add -tree_id $tree_id -parent_id $art_id -name "Dissertação de Mestrado" -description "Dissertação de Mestrado"
    category::add -tree_id $tree_id -parent_id $art_id -name "Dissertação de Doutorado" -description "Dissertação de Doutorado"

    category::add -tree_id $tree_id -parent_id $doc_id -name "Apostila" -description "Apostila"
    category::add -tree_id $tree_id -parent_id $doc_id -name "Livro" -description "Livro"
    category::add -tree_id $tree_id -parent_id $doc_id -name "Revista" -description "Revista"
    category::add -tree_id $tree_id -parent_id $doc_id -name "Tutorial" -description "Tutorial"
    
 
    set parent_id [category::add -tree_id $tree_id -parent_id $leg_id -name "Tipo Legislação" -description "Tipo Legislação"]
    category::add -tree_id $tree_id -parent_id $parent_id -name "Lei" -description "Lei"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Decreto Legislativo" -description "Decreto Legislastivo"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Resolução" -description "Resolução"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Decreto" -description "Decreto"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Resolução Normativa" -description "Resolução Normativa"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Resoluçao Administrativa" -description "Resolução Administrativa"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Ato Normativo" -description "Ato Normativo"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Ato Administrativo" -description "Ato Administrativo"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Portaria" -description "Portaria"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Aviso" -description "Aviso"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Medida Provisória" -description "Medida Provisória"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Consulta Pública" -description "Consulta Pública"


    set parent_id [category::add -tree_id $tree_id -parent_id $leg_id -name "Abrangência" -description "Abrangência"]
    category::add -tree_id $tree_id -parent_id $parent_id -name "Federal" -description "Federal"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Estadual/Distrital" -description "Estadual/Distrital"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Munincipal" -description "Munincipal"


    set parent_id [category::add -tree_id $tree_id -parent_id [db_null] -name "Licensa" -description "Licensa"]
    category::add -tree_id $tree_id -parent_id $parent_id -name "CC" -description "CC"
    category::add -tree_id $tree_id -parent_id $parent_id -name "DGPL" -description "DGPL"
    category::add -tree_id $tree_id -parent_id $parent_id -name "GPL" -description "GPL"
    


    set object_id [db_list select_object_id "
	select object_id 
	from acs_objects 
	where object_type = 'apm_package' 
	and package_id = $package_id
    "]

    category_tree::map -tree_id $tree_id -object_id $object_id

}



