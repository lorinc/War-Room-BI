create or replace view bi_todays_incidents as
	select
		pr.id,
		pr.created_at,
		pr.user_id,
		pr."isAbuse",
		pr."mediaUrls" is not null as has_media,
		pr."isInVerbatim"
	from pwa_report pr
	where created_at > current_date 
