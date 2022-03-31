create or replace view vday_bi__journey as
	with
		journey as (
			select  *
			from vday_bi__app_feed
		),
		
		users as (
			select *
			from vday_bi__users_w_locations
			where user_id is not null
		),
		
		results as (
			select *
			from journey
			left join users
			using(user_id)		
		)
		
	select * from results

go
