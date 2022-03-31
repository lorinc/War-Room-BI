create or replace view util_every_journal_questions as

	with results as (
		select distinct
			pj."version" as jversion,
			pjsg."order"::text || '/'
				|| pjs."order"::text || '/'
				|| pjq."order"::text || '/'
				|| pjqo."order"::text
			as combined_order,
			pjsg.title as gtitle,
			pjs.title as stitle,
			pjq."text" as qtext,
			pjq."textFieldLabel" as qtextlabel,
			pjqo.value as ovalue,
--			pja."text" as freetext_answer,
			pjqooa.reference

		from pwa_journey pj
		
		left join pwa_journey_step_group pjsg 
		on pj.id = pjsg.pwa_journey_id 
		
		left join pwa_journey_step pjs 
		on pjsg.id = pjs.pwa_journey_step_group_id
		
		left join pwa_journey_question pjq 
		on pjs.id = pjq.pwa_journey_step_id 
		
		left join pwa_journey_question_option pjqo 
		on pjq.id = pjqo.pwa_journey_question_id
		
		left join pwa_journey_answer pja 
		on pja.pwa_journey_question_id = pjq.id
		and pja.pwa_journey_id = pj.id
		
		left join pwa_journey_question_option_of_answer pjqooa 
		on pjqooa.pwa_journey_answer_id = pja.id
		and pjqooa.pwa_journey_question_option_id = pjqo.id
		
		where pj.version in (
			'v1.0.0-naplo', 
			'v1.0.0-statusz'
			)
		
		order by combined_order
	)

	select * from results

go
