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
			pjqo.value as ovalue
			
		from pwa_journey pj 
		
		left join pwa_journey_step_group pjsg 
		on pj.id = pjsg.pwa_journey_id 
		
		left join pwa_journey_step pjs 
		on pjsg.id = pjs.pwa_journey_step_group_id
		
		left join pwa_journey_question pjq 
		on pjs.id = pjq.pwa_journey_step_id 
		
		left join pwa_journey_question_option pjqo 
		on pjq.id = pjqo.pwa_journey_question_id
		
		where pj.version = '1.0.0-naplo'
		
		order by combined_order
	)
	
	select * from results

go
