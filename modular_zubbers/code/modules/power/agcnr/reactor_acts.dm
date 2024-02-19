/obj/machinery/atmospherics/components/trinary/nuclear_reactor/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/fuel_rod))
		return try_insert_fuel(W, user)
	if(istype(W, /obj/item/sealant))
		if(slagged)
			to_chat(user, span_warning("The reactor has been critically damaged!"))
			return FALSE
		if(temperature > REACTOR_TEMPERATURE_MINIMUM)
			to_chat(user, span_warning("You cannot repair [src] while the core temperature is above [REACTOR_TEMPERATURE_MINIMUM] kelvin."))
			return FALSE
		if(vessel_integrity >= 350)
			to_chat(user, span_warning("[src]'s seals are already in-tact, repairing them further would require a new set of seals."))
			return FALSE
		if(get_integrity() <= 50) //Heavily damaged.
			to_chat(user, span_warning("[src]'s reactor vessel is cracked and worn, you need to repair the cracks with a welder before you can repair the seals."))
			return FALSE
		while(do_after(user, 1 SECONDS, target=src))
			playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
			vessel_integrity += 10
			vessel_integrity = clamp(vessel_integrity, 0, initial(vessel_integrity))
			if(vessel_integrity >= 350) // Check if it's done
				to_chat(user, span_warning("[src]'s seals are already in-tact, repairing them further would require a new set of seals."))
				return FALSE
			user.visible_message(span_warning("[user] applies sealant to some of [src]'s worn out seals."), span_notice("You apply sealant to some of [src]'s worn out seals."))
		return TRUE
	return ..()

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/try_insert_fuel(obj/item/fuel_rod/rod, mob/user)
	if(!istype(rod))
		return FALSE
	if(slagged)
		to_chat(user, span_warning("The reactor has been critically damaged"))
		return FALSE
	if(temperature > REACTOR_TEMPERATURE_MINIMUM)
		to_chat(user, span_warning("You cannot insert fuel into [src] with the core temperature above [REACTOR_TEMPERATURE_MINIMUM] kelvin."))
		return FALSE
	if(fuel_rods.len >= REACTOR_MAX_FUEL_RODS)
		to_chat(user, span_warning("[src] is already at maximum fuel load."))
		return FALSE
	to_chat(user, span_notice("You start to insert [rod] into [src]..."))
	radiation_pulse(src, temperature)
	if(do_after(user, 2 SECONDS, target=src))
		fuel_rods += rod
		rod.forceMove(src)
		radiation_pulse(src, temperature) //Wear protective equipment when even breathing near a reactor!
		investigate_log("Rod added to reactor by [key_name(user)] at [AREACOORD(src)]", INVESTIGATE_REACTOR)
	return TRUE

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/crowbar_act(mob/living/user, obj/item/I)
	if(slagged)
		to_chat(user, span_warning("The fuel rods have melted into a radioactive lump."))
	var/removal_time = 5 SECONDS
	if(temperature > REACTOR_TEMPERATURE_MINIMUM)
		if(istype(I, /obj/item/crowbar/power)) // Snatch the reactor from the jaws of death!
			removal_time *= 2
		else
			to_chat(user, span_warning("You can't remove fuel rods while the reactor is operating above [REACTOR_TEMPERATURE_MINIMUM] kelvin!"))
			return TRUE
	if(!has_fuel())
		to_chat(user, span_notice("The reactor has no fuel rods!"))
		return TRUE
	var/obj/item/fuel_rod/rod = tgui_input_list(usr, "Select a fuel rod to remove", "Fuel Rods", fuel_rods)
	if(rod && istype(rod) && I.use_tool(src, user, removal_time))
		if(temperature > REACTOR_TEMPERATURE_MINIMUM)
			var/turf/T = get_turf(src)
			T.atmos_spawn_air("water_vapor=[pressure/100];TEMP=[temperature]")
		fuel_rods.Remove(rod)
		if(!user.put_in_hands(rod))
			rod.forceMove(user.loc)
	return TRUE

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/welder_act(mob/living/user, obj/item/I)
	if(slagged)
		to_chat(user, span_warning("The reactor has been critically damaged"))
		return TRUE
	if(temperature > REACTOR_TEMPERATURE_MINIMUM)
		to_chat(user, span_warning("You can't repair [src] while it is running at above [REACTOR_TEMPERATURE_MINIMUM] kelvin."))
		return TRUE
	if(get_integrity() > 50)
		to_chat(user, span_warning("[src] is free from cracks. Further repairs must be carried out with flexi-seal sealant."))
		return TRUE
	while(I.use_tool(src, user, 1 SECONDS, volume=40))
		vessel_integrity += 20
		if(get_integrity() > 50)
			to_chat(user, span_warning("[src] is free from cracks. Further repairs must be carried out with flexi-seal sealant."))
			return TRUE
		to_chat(user, span_notice("You weld together some of [src]'s cracks. This'll do for now."))
	return TRUE

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(istype(tool))
		to_chat(user, "<span class='notice'>You add \the [src]'s ID into the multitool's buffer.</span>")
		var/obj/item/multitool/multitool = tool
		multitool.set_buffer(src)
		return TRUE
