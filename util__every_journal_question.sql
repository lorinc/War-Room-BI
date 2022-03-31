select distinct
	pj."version" as jversion,
	pjsg."order" as gorder,
	pjsg.title as gtitle,
	pjs."order" as sorder,
	pjs.title as stitle,
	pjq."order" as qorder,
	pjq."text" as qtext,
	pjq."textFieldLabel" as qtextlabel,
	pjqo."order" as oorder,
	pjqo.value as ovalue
from pwa_journey pj 

left join pwa_journey_step_group pjsg 
on pj.id = pjsg.pwa_journey_id 

left join pwa_journey_step pjs 
on pjsg.id = pjs.pwa_journey_step_group_id

left join pwa_journey_question pjq 
on pjs.id = pjq.pwa_journey_step_id 

left join pwa_journey_question_option pjqo 
on pjq.id = pjqo.pwa_journey_question_id

where pj.version = '1.0.0-naplo'
