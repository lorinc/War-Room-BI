-- THIS VIEW MUST BE MATERIALIZED AFTER THE V-DAY JOURNEY GOT CREATED, BECAUSE IT IS STATIC
-- LET'S NOT RUN THIS QUERY THOUSAND TIMES A (V-)DAY WITH NO JUSTIFICATION

-- A DEDICATED VIEW - ON TOP OF THIS - SHOULD CONTAIN THE ANSWERS, THE DYNAMIC CONTENT
-- TBD - CAN WE LOAD STATIC DATA INTO SPICE AND READ THE DB FOR DYNAMIC CONTENT ONLY?? 

create or replace view bi_journey_questions as
	with
		journey_ids as (
			select
				id as pwa_journey_id,
				"version" as pwa_journey_version
			from
				pwa_journey
			where "version" in (
				'0.4.6-naplodemo',
				'0.4.6-statuszdemo',
				'0.4.7-naplodemo',
				'0.4.7-statuszdemo'
				)
		),
	
		journey_groups as (
			select
				ji.pwa_journey_version,
				jsg.id as pwa_journey_step_group_id,
				jsg.title as pwa_journey_step_group_title,
				jsg."order" as pwa_journey_step_group_order
			from pwa_journey_step_group jsg
			right join journey_ids ji -- predicate pushdown
			using(pwa_journey_id)     -- similar at each steps
		),
		
		journey_steps as (
			select
				jg.pwa_journey_version,
				jg.pwa_journey_step_group_title,
				jg.pwa_journey_step_group_order,
				js.id as pwa_journey_step_id,
				js.title as pwa_journey_step_title,
				js."isImportant" as pwa_journey_step_isImportant,
				js."order" as pwa_journey_step_order
			from pwa_journey_step js
			right join journey_groups jg
			using(pwa_journey_step_group_id)
		),
		
		journey_questions as (
			select
				js.pwa_journey_version,
				js.pwa_journey_step_group_title,
				js.pwa_journey_step_group_order,
				js.pwa_journey_step_title,
				js.pwa_journey_step_isImportant,
				js.pwa_journey_step_order,
				jq.id as pwa_journey_question_id,
				jq."text" as pwa_journey_question_text, -- recorded once per step, needs BI fix?
				jq."textFieldLabel" as pwa_journey_question_textFieldLabel,
				jq."order" as pwa_journey_question_order
			from pwa_journey_question jq 
			right join journey_steps js 
			using (pwa_journey_step_id)
		)
	
	select * from journey_questions
	
go
