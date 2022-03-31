create or replace view vday_bi__users_w_locations as
	with
	
		-- getting the latest record on every user
		delegation_filter as (
			select 
				id,
				user_id,
				max(updated_at_ts)
			from user_2_voting_locations uvl 
			where 
				"type" in ('accepted','manual') and
				user_id is not null
			group by user_id, id		
		),
		
		delegations as (
			select  
				uvl.user_id,
				uvl.delegation_status,
				uvl.voting_location_id,
				coalesce(uvl.oath_ind, 0) oath_ind,
				uvl.is_mkkp
			from user_2_voting_locations uvl
			right join delegation_filter df
			using(id)
		),
		
		delegations_w_locations as (
			select
				d.*,
				vl.voting_district_short_name as OEVK, 
				vl.town_id as town_id,
				vl.location_number as szk,
				vl.address as szk_address,
				vl.number_of_voters 
			from delegations d
			left join voting_locations vl
			on d.voting_location_id::text = vl.id
		),
		
		delegated_users_w_locations as (
			select
				dwl.*,
				ud.legal_name,
				u.email_address,
				u.phone_num,
				ud.personal_identity_num
			from delegations_w_locations dwl
			
			left join user_details ud
			on dwl.user_id = ud.user_id
	
			left join users u 
			on u.id = dwl.user_id
		)
		
		select * from delegated_users_w_locations

go
