create or replace view vday_bi__journal_aggr as
	with
		raw as (
			select 
				oevk,
				voting_location_id,
				szk,
				szk_address,
				pwa_journey_step_title,
				coalesce(
					pwa_journey_question_option_value,
					pwa_journey_answer_text 
				) as answer
			from
				vday_bi__journal vbj 
			where
				pwa_journey_step_title in (
					'Jegyzőkönyv',
					'Első szavazó',
					'Névjegyzékbe vettek száma',
					'Részvétel 11:00',
					'Részvétel 13:00',
					'Részvétel 15:00',
					'Részvétel 17:00',
					'Részvétel 18:30',
					'Részvétel 7:00',
					'Részvétel 9:00',
					'Részvétel záráskor',
					'Szavazóhelyiség bezárt',
					'Szavazóhelyiség kinyitott'
				)
			and voting_location_id is not null
			and (pwa_journey_question_option_value is not null
				or (pwa_journey_answer_text is not null
					and pwa_journey_answer_text <> ''))
		),
		
		aggregated as (
			select
				oevk,
				voting_location_id,
				szk,
				szk_address,
				pwa_journey_step_title,
				case
					when pwa_journey_step_title in (
						'Szavazóhelyiség kinyitott',
						'Első szavazó',
						'Szavazóhelyiség bezárt',
						'Jegyzőkönyv')
					then min(answer)
					else max(answer)
				end as valasz
			from raw
			group by 1,2,3,4,5
		)
		
		select * from aggregated
go
