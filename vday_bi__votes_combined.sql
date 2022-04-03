create or replace view vday_bi__votes as
	with 
	    egyeni_results as (
	        select 
	            substring(voting_location_id,1,5) oevk,
	            substring(voting_location_id,14,3) szk,
	            vl.address szk_address,
	            voting_location_id,
	            'Egyéni választókerületek eredménye' pwa_journey_step_title,
	            ej.name pwa_journey_question_option_value,
	            js.name jelolo_szerv,
	            result_num pwa_journey_answer_text,
	            row_number() over (partition by er.voting_location_id, er.egyeni_jelolt_id order by er.updated_at_ts desc) as order_num
	            
	        from manual_egyeni_results er, egyeni_jelolts ej, jelolo_szervs js, voting_locations vl
	        where 1=1 
	        and er.egyeni_jelolt_id = ej.id 
	        and ej.jelolo_szerv_id = js.id
	        and vl.id = voting_location_id
	    ),
	    egyeni_result_latest as (
	        select * from egyeni_results where order_num = 1
	    ),
	    jelolo_results as (
	        select 
	            substring(voting_location_id,1,5) oevk,
	            substring(voting_location_id,14,3) szk,
	            vl.address szk_address,
	            voting_location_id,
	            'Országos listás szavazás eredménye' pwa_journey_step_title,
	            js.name pwa_journey_question_option_value,
	            js.name jelolo_szerv,
	            result_num pwa_journey_answer_text,
	            row_number() over (partition by jr.voting_location_id, jr.jelolo_szerv_id order by jr.updated_at_ts desc) as order_num
	        from manual_jelolo_results jr, jelolo_szervs js, voting_locations vl
	        where 1=1 
	         and jr.jelolo_szerv_id = js.id
	         and vl.id = voting_location_id
	    ),
	    jelolo_result_latest as (
	        select * from jelolo_results where order_num = 1
	    ),
	    manual_results as (
	        select * from egyeni_result_latest union select * from jelolo_result_latest
	    ),
		results_journal as (
		   select
				oevk,
				szk_address,
				szk,
				voting_location_id,
				pwa_journey_step_title,
				case pwa_journey_question_option_value
				    when 'Ellenzéki Összefogás'  then 'Egységben Magyarországért'
				    when 'NÉP' then 'Normális Párt'
				    else pwa_journey_question_option_value
				end pwa_journey_question_option_value,
				coalesce(
					case jelolo_szerv
					    when 'Ellenzéki Összefogás'  then 'Egységben Magyarországért'
				        when 'NÉP' then 'Normális Párt'
				        else jelolo_szerv
				    end,
					case pwa_journey_question_option_value
					    when 'Ellenzéki Összefogás'  then 'Egységben Magyarországért'
				        when 'NÉP' then 'Normális Párt'
				        else pwa_journey_question_option_value
				    end
				) as jelolo_szerv,
				pwa_journey_answer_text::int,
				row_number() over (partition by vbj.voting_location_id, vbj.pwa_journey_question_option_value order by pwa_journey_answer_updated_at desc) as order_num
				--max(pwa_journey_answer_text)::int as pwa_journey_answer_text
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
			--group by 1,2,3,4,5,6,7
		),
		results_journal_latest as (
		    select * from results_journal where order_num = 1
		),
		results_all as (
		    select
		        coalesce(res.oevk, mres.oevk) oevk,
		        coalesce(res.szk_address, mres.szk_address) szk_address,
		        coalesce(res.szk, mres.szk) szk,
		        coalesce(res.voting_location_id, mres.voting_location_id) voting_location_id,
		        coalesce(res.pwa_journey_step_title, mres.pwa_journey_step_title) pwa_journey_step_title,
		        coalesce(res.pwa_journey_question_option_value, mres.pwa_journey_question_option_value) pwa_journey_question_option_value,
		        coalesce(res.jelolo_szerv, mres.jelolo_szerv) jelolo_szerv,
		        coalesce(res.pwa_journey_answer_text, mres.pwa_journey_answer_text)::int pwa_journey_answer_text
		    from results_journal_latest res
		    full outer join manual_results mres
		    on 1 = 1
		        and res.oevk = mres.oevk
		        and res.szk_address = mres.szk_address
		        and res.szk = mres.szk
		        and res.voting_location_id = mres.voting_location_id
		        and res.pwa_journey_step_title = mres.pwa_journey_step_title
		        and res.pwa_journey_question_option_value = mres.pwa_journey_question_option_value
		        and res.jelolo_szerv = mres.jelolo_szerv
	    )
	select * from results_all
go
