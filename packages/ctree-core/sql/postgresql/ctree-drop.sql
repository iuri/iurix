select content_folder__unregister_content_type(-100,'c_tree','t');
select content_type__drop_type('c_tree', 't', 't');

select content_folder__unregister_content_type(-100,'c_type','t');
select content_type__drop_type('c_type', 't', 't');

select content_folder__unregister_content_type(-100,'c_segmenttype','t');
select content_type__drop_type('c_segmenttype', 't', 't');

select content_folder__unregister_content_type(-100,'c_segmentvariation','t');
select content_type__drop_type('c_segmentvariation', 't', 't');


select content_folder__unregister_content_type(-100,'c_element','t');
select content_type__drop_type('c_element', 't', 't');

