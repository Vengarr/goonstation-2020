/obj/machinery/optable
	name = "Operating Table"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	desc = "A table that allows qualified professionals to perform delicate surgeries."
	density = 1
	anchored = 1.0
	mats = 25
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS
	var/mob/living/carbon/human/victim = null
	var/strapped = 0.0
	var/allow_unbuckle = 1
	var/mob/living/buckled_guy = null

	var/obj/machinery/computer/operating/computer = null
	var/id = 0.0

	proc/buckle_in(mob/living/to_buckle, var/stand = 0) //Handles the actual buckling in
		to_buckle.setStatus("buckled", duration = null)
		return

	proc/unbuckle() //Ditto but for unbuckling
		if (src.buckled_guy)
			src.buckled_guy.end_chair_flip_targeting()

	proc/buckle_mob(var/mob/living/carbon/C as mob, var/mob/user as mob)
		if (!C || (C.loc != src.loc))
			return // yeesh

		if (!ticker)
			user.show_text("You can't buckle anyone in before the game starts.", "red")
			return
		if (get_dist(src, user) > 1)
			user.show_text("[src] is too far away!", "red")
			return
		if ((!(iscarbon(C)) || C.loc != src.loc || user.restrained() || user.stat || user.getStatusDuration("paralysis") || user.getStatusDuration("stunned") || user.getStatusDuration("weakened") ))
			return

		if (C == user)
			user.visible_message("<span style=\"color:blue\"><b>[C]</b> buckles in!</span>", "<span style=\"color:blue\">You buckle yourself in.</span>")
		else
			user.visible_message("<span style=\"color:blue\"><b>[C]</b> is buckled in by [user].</span>", "<span style=\"color:blue\">You buckle in [C].</span>")
		buckle_in(C)
		if (isdead(C) && C != user && emergency_shuttle && emergency_shuttle.location == SHUTTLE_LOC_STATION) // 1 should be SHUTTLE_LOC_STATION
			var/area/shuttle/escape/station/A = get_area(C)
			if (istype(A))
				user.unlock_medal("Leave no man behind!", 1)
		src.add_fingerprint(user)

	proc/unbuckle_mob(var/mob/M as mob, var/mob/user as mob)
		if (M.buckled && !user.restrained())
			if (allow_unbuckle)
				if (M != user)
					user.visible_message("<span style=\"color:blue\"><b>[M]</b> is unbuckled by [user].</span>", "<span style=\"color:blue\">You unbuckle [M].</span>")
				else
					user.visible_message("<span style=\"color:blue\"><b>[M]</b> unbuckles.</span>", "<span style=\"color:blue\">You unbuckle.</span>")
				unbuckle()
			else
				user.show_text("Seems like the buckle is firmly locked into place.", "red")

			src.add_fingerprint(user)

	buckle_in(mob/living/to_buckle)
		to_buckle.lying = 1
		if (src.anchored)
			to_buckle.anchored = 1
		to_buckle.buckled = src
		src.buckled_guy = to_buckle
		to_buckle.set_loc(src.loc)

		to_buckle.set_clothing_icon_dirty()
		playsound(get_turf(src), "sound/misc/belt_click.ogg", 50, 1)
		to_buckle.setStatus("buckled", duration = null)

	unbuckle()
		..()
		if(src.buckled_guy)
			buckled_guy.anchored = 0
			buckled_guy.buckled = null
			buckled_guy.force_laydown_standup()
			src.buckled_guy = null
			playsound(get_turf(src), "sound/misc/belt_click.ogg", 50, 1)

/obj/machinery/optable/New()
	..()
	SPAWN_DBG(5)
		src.computer = locate(/obj/machinery/computer/operating, orange(2,src))

/obj/machinery/optable/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				src.set_density(0)
		else
	return

/obj/machinery/optable/blob_act(var/power)
	if(prob(power * 2.5))
		qdel(src)

/obj/machinery/optable/attack_hand(mob/user as mob)
	if (usr.is_hulk())
		user.visible_message("<span style=\"color:red\">[user] destroys the table.</span>")
		src.set_density(0)
		qdel(src)
	for (var/mob/M in src.loc)
		src.unbuckle_mob(M, user)
	return

/obj/machinery/optable/CanPass(atom/movable/O as mob|obj, target as turf, height=0, air_group=0)
	if (air_group || (height==0))
		return 1
	if (!O)
		return 0
	if ((O.flags & TABLEPASS || istype(O, /obj/newmeteor)))
		return 1
	else
		return 0
	return

/obj/machinery/optable/proc/check_victim()
	if(locate(/mob/living/carbon/human, src.loc))
		var/mob/M = locate(/mob/living/carbon/human, src.loc)
		if(M.resting)
			src.victim = M
			icon_state = "table2-active"
			return 1
	src.victim = null
	icon_state = "table2-idle"
	return 0

/obj/machinery/optable/process()
	check_victim()

/obj/machinery/optable/attackby(obj/item/W as obj, mob/user as mob)
	if (issilicon(user)) return
	if (istype(W, /obj/item/electronics/scanner)) return // hack
	if (istype(W, /obj/item/grab))
		if(ismob(W:affecting))
			var/mob/M = W:affecting
			M.resting = 1
			M.force_laydown_standup()
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				H.hud.update_resting()
			M.set_loc(src.loc)
			src.visible_message("<span style=\"color:red\">[M] has been laid on the operating table by [user].</span>")
			for(var/obj/O in src)
				O.set_loc(src.loc)
			src.add_fingerprint(user)
			icon_state = "table2-active"
			src.victim = M
			qdel(W)
			return
	return

/obj/machinery/optable/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (!isliving(user))
		boutput(user, "<span style=\"color:red\">You're dead! What the hell could surgery possibly do for you NOW, dumbass?!</span>")
		return
	if (!ismob(O))
		boutput(user, "<span style=\"color:red\">You can't put that on the operating table!</span>")
		return
	if (iscritter(O))
		boutput(user, "<span style=\"color:red\">You don't know how to operate on this. You never went to vet school!</span>")
		return
	if (!ishuman(O))
		boutput(user, "<span style=\"color:red\">You can only put carbon lifeforms on the operating table.</span>")
		return
	if (get_dist(user,src) > 1)
		boutput(user, "<span style=\"color:red\">You need to be closer to the operating table.</span>")
		return
	if (get_dist(user,O) > 1)
		boutput(user, "<span style=\"color:red\">Your target needs to be near you to put them on the operating table.</span>")
		return

	var/mob/living/carbon/C = O
	if(src.loc == C.loc)
		src.buckle_mob(O, user)
		return
	if (user == C)
		src.visible_message("<span style=\"color:red\"><b>[user.name]</b> lies down on [src].</span>")
		user.resting = 1
		user.force_laydown_standup()
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			H.hud.update_resting()
		user.set_loc(src.loc)
		src.victim = user
	else
		src.visible_message("<span style=\"color:red\"><b>[user.name]</b> starts to move [C.name] onto the operating table.</span>")
		if (do_mob(user,C,30))
			C.resting = 1
			C.force_laydown_standup()
			if (ishuman(C))
				var/mob/living/carbon/human/H = C
				H.hud.update_resting()
			C.set_loc(src.loc)
			src.victim = C
		else
			boutput(user, "<span style=\"color:red\">You were interrupted!</span>")
	return


	return