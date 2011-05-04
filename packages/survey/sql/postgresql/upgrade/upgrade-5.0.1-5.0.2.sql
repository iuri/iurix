-- Adds a column to the survey_questions table
ALTER TABLE survey_questions
ADD COLUMN num_answers INTEGER;


-- Fixes the response removal
CREATE OR REPLACE FUNCTION survey_response__remove(integer)
  RETURNS integer AS $$
declare
  remove__response_id           alias for $1;
  v_response_row                survey_responses%ROWTYPE;
begin
    for v_response_row in select response_id from survey_responses
	where initial_response_id=remove__response_id
	or response_id = remove__response_id
    loop
	PERFORM survey_response__del(v_response_row.response_id);
    end loop;

    return 0;

end;
$$ LANGUAGE 'plpgsql' VOLATILE;
