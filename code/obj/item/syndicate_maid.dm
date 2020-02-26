/obj/item/clothing/under/syndie_maid
	name = "Syndicate Maid Dress"
	desc = "A commitment...to service."
	icon_state = "syndiemaid"
	item_state = "syndiemaid"
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
	c_flags = SPACEWEAR // made of only the finest space-silk.
	contraband = 10 // Make them panic.
	is_syndicate = 1 //Good idea not to have a ton of these around.
	cant_self_remove = 1 //Professionals have standards.
	
	setupProperties()
		..()
		setProperty("meleeprot", 3)
		setProperty("viralprot", 50)

	equipped(var/mob/user, var/slot)
		SPAWN_DBG(10)
			playsound(src.loc, "sound/vox/time.ogg", 100, 1)
			SPAWN_DBG(10)
				playsound(src.loc, "sound/vox/for.ogg", 100, 1)
				SPAWN_DBG(10)
					playsound(src.loc, "sound/vox/cleanup.ogg", 100, 1)

/obj/item/clothing/head/syndie_maidh
	name = "Maid Headband"
	desc = "A little ruffle with lace, to wear on the head. It gives you super cleaning powers*!<br><small>*The Syndicate is not responsible for misuse of cleaning powers</small>"
	icon_state = "syndiemaidh"
	item_state = "syndiemaidh"
	cant_self_remove = 1
	is_syndicate = 1
	c_flags = SPACEWEAR

	setupProperties()
		..()
		setProperty("viralprot", 50)
	
/obj/item/clothing/shoes/syndie_maids
	name = "Syndicate Maid Shoes"
	desc = "Their sound strikes fear into dirty hearts."
	icon_state = "syndiemaids"
	item_state = "syndiemaids"
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
	cant_self_remove = 1 //Not that you'd ever want to
	is_syndicate = 1
	step_sound = "step_highheel"
	step_priority = STEP_PRIORITY_MED //Lets try this?
	laces = LACES_NONE
	kick_bonus = 5 // Goes with the gimmick of slipping people and beating the shit out of them.
	c_flags = NOSLIP 

/obj/item/reagent_containers/glass/bottle/maid_acid
	name = "'Cleaner' bottle"
	desc = "A large bottle filled with...'cleaning' fluid."
	icon_state = "largebottle-labeled"
	initial_volume = 400
	initial_reagents = "pacid"
	amount_per_transfer_from_this = 10

/obj/storage/crate/maid
	name = "Syndicate Maid Kit"
	desc = "A featureless crate, polished obsessively to a mirror sheen."
	spawn_contents = list(/obj/item/clothing/under/syndie_maid,
	/obj/item/clothing/head/syndie_maidh,
	/obj/item/clothing/shoes/syndie_maids,
	/obj/item/mop/old,
	/obj/mopbucket,
	/obj/item/reagent_containers/glass/bottle/maid_acid,
	/obj/item/reagent_containers/glass/bottle/cleaner
	)

/datum/syndicate_buylist/traitor/maidoutfit
	name = "Syndicate Maid Set"
	item = /obj/storage/crate/maid
	cost = 7
	desc = "Less of a set of equipment, more of a calling. Lets you clean up messes and wastes of space."
	job = list("Janitor", "Assistant", "Waiter", "Bartender", "Chef")
	blockedmode = list(/datum/game_mode/spy, /datum/game_mode/revolution,)