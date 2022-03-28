create or replace view bi_incidents_w_location_and_usr_details as
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
				voting_location_id,
				coalesce(oath_ind, 0) oath_ind,
				is_mkkp
			from user_2_voting_locations uvl  
			where delegation_status in (
				'delegated', 
				'delegation_successful')	
		),
		
		delegations_w_locations as (
			select
				d.user_id,
				d.analog_user_id,
				d.voting_location_id,
				d.oath_ind,
				d.is_mkkp,
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
				dwl.user_id,
				dwl.voting_location_id,
				dwl.oath_ind,
				dwl.is_mkkp,
				dwl.OEVK, 
				dwl.town_id,
				dwl.szk,
				dwl.szk_address,
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
		),
		
		incidents as (
			select
				pr.id,
				pr.created_at,
				pr.user_id,
				pr."isAbuse",
				pr."mediaUrls" is not null as has_media,
				pr."isInVerbatim"
			from pwa_report pr
			-- we want to cover 48hrs, plus the db is 1hrs behind local time
			where created_at > current_date + interval '-1 day 1 hour'
		),
		
		incidents_w_usr_data as (
			select
				*
			from incidents i
			left join delegated_users_w_locations
			using(user_id)
		)
		
		select * from incidents_w_usr_data
go
