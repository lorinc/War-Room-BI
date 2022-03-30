create or replace view vday_bi__incidents as
	with
		incidents as (
			select
				pr.id,
				pr.created_at,
				pr.user_id,
				pr."isAbuse",
				pr."mediaUrls" is not null as has_media,
				pr."isInVerbatim"
			from pwa_report pr
			where created_at > current_date + interval '-1 day'
		),
		
		incidents_w_usr_data as (
			select
				*
			from incidents
			left join vday_bi__users_w_locations
			using(user_id)
		)
		
		select * from incidents_w_usr_data
go
