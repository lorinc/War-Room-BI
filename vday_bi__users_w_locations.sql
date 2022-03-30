create or replace view vday_bi__users_w_locations as
	with
		delegations as (
			select  
				user_id,
				analog_user_id,
				case
					when user_id is null
					then 'analog'
					else 'digital'
				end as user_type,
				delegation_status,
				voting_location_id,
				coalesce(oath_ind, 0) oath_ind,
				is_mkkp
			from user_2_voting_locations uvl  	
		),
		
		delegations_w_locations as (
			select
				d.*,
				vl.voting_district_short_name as OEVK, 
				vl.town_id as town_id,
				vl.location_number as szk,
				vl.address as szk_address
			from delegations d
			left join voting_locations vl
			on d.voting_location_id::text = vl.id
		),
		
		delegated_users_w_locations as (
			select
				dwl.*,
				coalesce(ud.legal_name, au.full_name) as legal_name,
				coalesce(u.email_address, au.email_address) as email_address,
				coalesce(u.phone_num, au.phone_num) as phone_num,
				coalesce(ud.personal_identity_num, au.identity_num) as identity_number
			from delegations_w_locations dwl
			
			left join user_details ud
			on dwl.user_id = ud.user_id
	
			left join users u 
			on u.id = dwl.user_id 
			
			left join analog_users au
			on dwl.analog_user_id = au.id
		)
		
		select * from delegated_users_w_locations

go
