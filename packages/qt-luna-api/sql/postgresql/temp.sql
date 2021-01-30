

CREATE OR REPLACE FUNCTION inline_0 () RETURNS integer AS $$
DECLARE
  v_userinfo_id integer;
BEGIN

    v_userinfo_id := nextval('user_info_id_seq');

    PERFORM userinfo__new(v_userinfo_id,'19f69e54-6476-4721-9e29-ae6e411c5256', '55516825-3b7f-47f6-869a-b5fdf6deb03e', null, null, 12143763);

    v_userinfo_id := nextval('user_info_id_seq');
    
    PERFORM userinfo__new(v_userinfo_id,'3e0058dd-5552-4ffd-bd50-edeeedeba123', '7195f0f9-8c9a-46c0-aa88-5d0d5e52c98b', null, null, 12659234);

    v_userinfo_id := nextval('user_info_id_seq');
    
    PERFORM userinfo__new(v_userinfo_id,'fccf9ec6-ad9e-45af-a8c9-4deded26b826', '7554dabe-e1d4-4ad9-b14b-fccbe6c44c75', null, null, 12661940);

    v_userinfo_id := nextval('user_info_id_seq');
    
    PERFORM userinfo__new(v_userinfo_id,'359f7217-1d0b-44e8-a59e-a94da9f97feb', 'a2439cd8-42be-425d-ba94-03594c87bcc4', null, null, 12650918 );


    v_userinfo_id := nextval('user_info_id_seq');
    
    PERFORM userinfo__new(v_userinfo_id,'d654f36b-c180-40d1-946c-31c4f6a78b46', '55ca8b8a-9b79-4a48-b076-4f1ef55ea587', null, null, 12651191);

    v_userinfo_id := nextval('user_info_id_seq');
    
    PERFORM userinfo__new(v_userinfo_id,'32b91b54-8035-4e09-963a-3a0bc524a50f', '4551dc3d-7068-4102-b2b7-43333016e9d1', null, null, 12651143);

    v_userinfo_id := nextval('user_info_id_seq');
    
    PERFORM userinfo__new(v_userinfo_id,'20a8953a-9f8b-477d-af1e-40a22517e41e', '43239433-7623-4c6e-9549-e01f56f0850d', null, null, 12650813);


    return 0;

END;
$$ LANGUAGE plpgsql;


SELECT inline_0 ();
DROP FUNCTION inline_0 ();
