GLOBAL_LIST_EMPTY(asteroid_spawn_markers)

/obj/machinery/computer/mineral_magnet
	name = "Asteroid Magnet Computer"
	icon = 'modular_zubbers/icons/obj/machines/terminals.dmi'
	icon_state = "magnet"
	req_access = list(ACCESS_MINING)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

	var/datum/map_template/asteroid/current_asteroid
	var/turf/target_location = null //Where to load the asteroid
	var/cooldown = FALSE
	var/tier = 1 //Upgrade via science
	var/turf_type = /turf/open/space/basic

/obj/machinery/computer/mineral_magnet/LateInitialize()
	. = ..()
	//Find our ship's asteroid marker. This allows multi-ship mining.
	for(var/obj/effect/landmark/L in GLOB.asteroid_spawn_markers)
		target_location = get_turf(L)

/obj/machinery/computer/mineral_magnet/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/deepcore_upgrade))
		var/obj/item/deepcore_upgrade/DU = I
		if(DU.tier > tier)
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
			to_chat(user, "<span class='notice'>You slot [I] into [src], allowing it to lock on to a wider variety of asteroids.</span>")
			tier = DU.tier
			qdel(DU)
			icon_state = "magnet-[tier]"
			return TRUE
	return ..()

/obj/machinery/computer/mineral_magnet/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(href_list["pull_asteroid"])
		pull_in_asteroid(usr)
	if(href_list["push_asteroid"])
		if(alert(usr, "Are you sure you want to release the currently held asteroid?",name,"Yes","No") == "Yes" && Adjacent(usr))
			start_push()

/obj/machinery/computer/mineral_magnet/attack_hand(mob/user)
	if(!target_location)
		return
	var/dat
	dat += "<h2>Current asteroid:  </h2>"
	if(!current_asteroid)
		dat += "<A href='?src=\ref[src];pull_asteroid=1'>Pull in asteroid</font></A><BR>"
	else
		dat += "<A href='?src=\ref[src];push_asteroid=1'>Push away asteroid</font></A><BR>"
	var/datum/browser/popup = new(user, "Pull Asteroids", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/turf/closed/indestructible/boarding_cordon
	name = "ship interior cordon"

/datum/map_template/asteroid
	var/list/core_composition = list(/turf/closed/mineral/iron, /turf/closed/mineral/titanium)

/datum/map_template/asteroid/New(path = null, rename = null, cache = FALSE, var/list/core_comp)
	. = ..()
	if(core_comp)
		core_composition = core_comp

/datum/map_template/asteroid/load(turf/T, centered = FALSE, magnet_load = FALSE) ///Add in vein if applicable.
	. = ..()
	if(!length(core_composition)) //No core composition? you a normie asteroid.
		return
	var/turf/center = null
	if(centered)
		center = T
	else
		center = locate(T.x+(width/2), T.y+(height/2), T.z)
	for(var/turf/target_turf as() in RANGE_TURFS(rand(3,5), center)) //Give that boi a nice core.
		if(prob(85)) //Bit of random distribution
			var/turf_type = pick(core_composition)
			target_turf.ChangeTurf(turf_type) //Make the core itself
	// add boundaries
	var/turf/bottom_left = T
	if(centered)
		bottom_left = locate(T.x - (width/2), T.y - (height/2), T.z)

	if(!magnet_load)
		for(var/i = 0; i <= width; i++)
			// top and bottom
			var/turf/border = locate(bottom_left.x + i, bottom_left.y, bottom_left.z)
			border.ChangeTurf(/turf/closed/indestructible/boarding_cordon)
			border = locate(bottom_left.x + i, bottom_left.y + height, bottom_left.z)
			border.ChangeTurf(/turf/closed/indestructible/boarding_cordon)
		for(var/j = 1; j < (height); j++)
			// left and right
			var/turf/border = locate(bottom_left.x, bottom_left.y + j, bottom_left.z)
			border.ChangeTurf(/turf/closed/indestructible/boarding_cordon)
			border = locate(bottom_left.x + width, bottom_left.y + j, bottom_left.z)
			border.ChangeTurf(/turf/closed/indestructible/boarding_cordon)

/obj/effect/landmark/asteroid_spawn
	name = "Asteroid Spawn"

/obj/effect/landmark/asteroid_spawn/New()
	..()
	GLOB.asteroid_spawn_markers += src

/obj/effect/landmark/asteroid_spawn/Destroy()
	GLOB.asteroid_spawn_markers -= src
	return ..()

/obj/machinery/computer/mineral_magnet/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(href_list["pull_asteroid"])
		pull_in_asteroid(usr)
	if(href_list["push_asteroid"])
		if(alert(usr, "Are you sure you want to release the currently held asteroid?",name,"Yes","No") == "Yes" && Adjacent(usr))
			start_push()

	attack_hand(usr) //Refresh window

/obj/machinery/computer/mineral_magnet/proc/pull_in_asteroid(mob/user)
	if(cooldown)
		say("ERROR: Magnetisation circuits recharging...")
		return FALSE
	var/list/asteroids = list()
	if(!length(asteroids))
		to_chat(user, "<span class='notice'>Cannot lock on to any asteroids near</span>")
		return FALSE
	var/obj/structure/asteroid/AS = input(usr, "Select target:", "Target") as null|anything in asteroids
	if(!AS || !length(AS.core_composition))
		return FALSE
	// "<span class='warning'>DANGER: Magnet has locked on to an asteroid. Vacate the asteroid cage immediately.</span>")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 1 MINUTES)
	var/list/potential_asteroids = flist("_maps/map_files/Mining/nsv13/asteroids/")
	current_asteroid = new /datum/map_template/asteroid("_maps/map_files/Mining/nsv13/asteroids/[pick(potential_asteroids)]", null, FALSE, AS.core_composition) //Set up an asteroid
	addtimer(CALLBACK(src, PROC_REF(load_asteroid)), 10 SECONDS)
	qdel(AS)

/obj/machinery/computer/mineral_magnet/proc/load_asteroid()
	current_asteroid.load(target_location, FALSE, TRUE)

/obj/machinery/computer/mineral_magnet/proc/start_push()
	if(cooldown)
		say("ERROR: Magnetisation circuits recharging...")
		return
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 1 MINUTES)
	//linked.relay('nsv13/sound/effects/ship/general_quarters.ogg', "<span class='warning'>DANGER: An asteroid is now being detached from [linked]. Vacate the asteroid cage immediately.</span>")
	addtimer(CALLBACK(src, PROC_REF(push_away_asteroid)), 30 SECONDS)

/obj/machinery/computer/mineral_magnet/proc/push_away_asteroid()
	for(var/turf/T as() in current_asteroid.get_affected_turfs(target_location, FALSE)) //nuke
		for(var/atom/A as() in T.contents)
			if(!ismob(A) && !istype(A, /obj/effect/landmark/asteroid_spawn))
				qdel(A)
		T.ChangeTurf(turf_type)
	QDEL_NULL(current_asteroid)
