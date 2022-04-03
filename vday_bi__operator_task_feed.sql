create or replace view v_day_dashboard as
	with results as (
		select
			user_id,
			pwa_journey_step_group_title,
			pwa_journey_step_title,
			pwa_journey_question_id,
			pwa_journey_question_text,
			pwa_journey_answer_id,
			pwa_journey_answer_created_at,
			pwa_journey_answer_updated_at,
			pwa_journey_answer_text,
			pwa_journey_question_option_value,
			issue_label,
			voting_location_id,
			oath_ind,
			is_mkkp,
			oevk,
			town_id,
			szk,
			szk_address,
			legal_name,
			email_address,
			phone_num,
			'' as identity_number
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
