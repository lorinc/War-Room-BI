create or replace view vday_bi__votes as
	with results as (
		select
			oevk,
			szk_address,
			szk,
			voting_location_id,
			pwa_journey_step_title,
			pwa_journey_question_option_value,
			coalesce(
				jelolo_szerv,
				pwa_journey_question_option_value
			) as jelolo_szerv,
			max(pwa_journey_answer_text)::int as pwa_journey_answer_text
		from vday_bi__journal vbj 
		where
			pwa_journey_step_title in (
				'Nemzetiségi listás szavazás eredménye',
				'Országos listás szavazás eredménye',
				'Egyéni választókerületek eredménye')
		and not (
			pwa_journey_step_title = 'Egyéni választókerületek eredménye'
			and	jelolo_szerv is null)
		and pwa_journey_question_option_value is not null
		and voting_location_id is not null
		group by 1,2,3,4,5,6,7
	)
select * from results
go
