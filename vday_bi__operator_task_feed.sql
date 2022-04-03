create or replace view v_day_dashboard as
	with results as (
		select
			user_id,
			oevk,
			pwa_journey_question_id,
			voting_location_id,
			legal_name,
			pwa_journey_answer_created_at,
			szk,
			szk_address,
			phone_num,
			issue_label
		from
			vday_bi__journey vbj 
		right join
			v_day_non_happy_path_questions nhpq
			on nhpq.question_id = vbj.pwa_journey_question_id 
			and nhpq.answer = vbj.pwa_journey_question_option_value
		where legal_name is not null
	)
	select * from results
go
