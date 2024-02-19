/// See code/__DEFINES/reactor.dm for all the defines used

//Remember kids. If the reactor itself is not physically powered by an APC, it cannot shove coolant in!

//Helper proc to set a new looping ambience, and play it to any mobs already inside of that area.


/obj/machinery/atmospherics/components/trinary/nuclear_reactor
	name = "\improper Advanced Gas-Cooled Nuclear Reactor"
	desc = "A tried and tested design which can output stable power at an acceptably low risk. The moderator can be changed to provide different effects."
	icon = 'modular_zubbers/code/modules/power/agcnr/icons/reactor.dmi'
	icon_state = "reactor_map"
	pixel_x = -32
	pixel_y = -32
	density = FALSE //It burns you if you're stupid enough to walk over it.
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_color = LIGHT_COLOR_CYAN
	dir = 2 //Less headache inducing
	var/id = null //Change me mappers
	//Variables essential to operation
	var/active = FALSE
	var/temperature = T20C //Lose control of this -> Meltdown
	var/vessel_integrity = 400 //How long can the reactor withstand overpressure / meltdown? This gives you a fair chance to react to even a massive pipe fire
	var/pressure = 0 //Lose control of this -> Blowout
	var/K = 0 //Rate of reaction.
	var/desired_k = 0
	var/control_rod_effectiveness = 0.65 //Starts off with a lot of control over K. If you flood this thing with plasma, you lose your ability to control K as easily.
	var/power = 0 //0-100%. A function of the maximum heat you can achieve within operating temperature
	var/power_modifier = 1 //Upgrade me with parts, science! Flat out increase to physical power output when loaded with plasma.
	var/list/fuel_rods = list()
	//Secondary variables.
	var/counter = 0 // Base ID starting point
	var/gas_absorption_effectiveness = 0.5
	var/gas_absorption_constant = 0.5 //We refer to this one as it's set on init, randomized.
	var/minimum_coolant_level = MINIMUM_MOLE_COUNT
	var/next_warning = 0 //To avoid spam.
	var/last_power_produced = 0 //For logging purposes
	var/next_flicker = 0 //Light flicker timer
	var/base_power_modifier = REACTOR_POWER_FLAVOURISER
	var/slagged = FALSE //Is this reactor even usable any more?
	//Console statistics.
	var/last_coolant_temperature = 0
	var/last_output_temperature = 0
	var/last_heat_delta = 0 //For administrative cheating only. Knowing the delta lets you know EXACTLY what to set K at.
	var/last_user = null
	var/current_desired_k = null
	var/obj/item/radio/radio
	var/key_type = /obj/item/encryptionkey/headset_eng
	//Which channels should it broadcast to?
	var/engi_channel = RADIO_CHANNEL_ENGINEERING
	var/crew_channel = RADIO_CHANNEL_COMMON
	initialize_directions = NORTH|WEST|SOUTH

	var/has_hit_emergency = FALSE
	var/evacuation_procedures = FALSE

	//Data, because graphs are cool
	var/list/kpaData = list()
	var/list/powerData = list()
	var/list/tempCoreData = list()
	var/list/tempInputData = list()
	var/list/tempOutputData = list()

	var/obj/structure/cable/powercable

//Use this in your maps if you want everything to be preset.
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/preset
	id = "default_reactor_for_lazy_mappers"

/// Return a unique ID
/proc/getnewid()
	var/counter = 0
	counter += 1
	return counter

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/New()
	. = ..()
	if(isnull(id))
		id = getnewid()

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/get_integrity()
	..()
	return round(100 * vessel_integrity / initial(vessel_integrity), 0.01)

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/examine(mob/user)
	. = ..()
	if(Adjacent(src, user) || isobserver(user))
		var/msg
		if(slagged)
			msg = span_boldwarning("The reactor is destroyed. Its core lies exposed!")
		else
			msg = span_warning("The reactor looks operational.")
		switch(get_integrity())
			if(0 to 10)
				msg = span_boldwarning("[src]'s seals are dangerously warped and you can see cracks all over the reactor vessel!")
			if(10 to 40)
				msg = span_boldwarning("[src]'s seals are heavily warped and cracked!")
			if(40 to 60)
				msg = span_warning("[src]'s seals are holding, but barely. You can see some micro-fractures forming in the reactor vessel.")
			if(60 to 80)
				msg = span_warning("[src]'s seals are in-tact, but slightly worn. There are no visible cracks in the reactor vessel.")
			if(80 to 90)
				msg = span_notice("[src]'s seals are in good shape, and there are no visible cracks in the reactor vessel.")
			if(95 to 100)
				msg = span_notice("[src]'s seals look factory new, and the reactor's in excellent shape.")
		. += msg

//Admin procs to mess with the reaction environment.

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/lazy_startup()
	for(var/I=0;I<5;I++)
		fuel_rods += new /obj/item/fuel_rod(src)
	message_admins("Reactor started up by admins in [ADMIN_VERBOSEJMP(src)]")
	start_up()

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/deplete()
	for(var/obj/item/fuel_rod/FR in fuel_rods)
		FR.depletion = 100

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/Initialize(mapload)
	. = ..()
	icon_state = "reactor_off"
	gas_absorption_effectiveness = rand(5, 6)/10 //All reactors are slightly different. This will result in you having to figure out what the balance is for K.
	gas_absorption_constant = gas_absorption_effectiveness //And set this up for the rest of the round.

	radio = new(src)
	radio.keyslot = new key_type(radio)
	radio.subspace_transmission = TRUE
	radio.use_command = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()

	STOP_PROCESSING(SSmachines, src) //We'll handle this one ourselves.

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/process()
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(!C || !C.powernet)
		return
	else
		C.powernet.newavail += last_power_produced

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/process_atmos(delta_time)
	//Let's get our gasses sorted out.
	var/datum/gas_mixture/coolant_input = airs[COOLANT_INPUT_GATE]
	var/datum/gas_mixture/moderator_input = airs[MODERATOR_INPUT_GATE]
	var/datum/gas_mixture/coolant_output = airs[COOLANT_OUTPUT_GATE]

	coolant_input.volume = 600
	moderator_input.volume = 600
	coolant_output.volume = 600

	var/power_produced = 0 // How much power we're producing from the moderator
	var/radioactivity_spice_multiplier = 1 + get_fuel_power() //Some gasses make the reactor a bit spicy.
	var/depletion_modifier = 0.035 //How rapidly do your rods decay
	gas_absorption_effectiveness = gas_absorption_constant
	last_power_produced = 0

	//Make absolutely sure that pipe connections are updated
	update_parents()

	//First up, handle moderators!
	if(active && moderator_input.total_moles() >= minimum_coolant_level)
		// Fuel types: increases power and K

		var/total_fuel_moles = 0
		total_fuel_moles += moderator_input.gases[/datum/gas/plasma][MOLES] * PLASMA_FUEL_POWER
		total_fuel_moles += moderator_input.gases[/datum/gas/tritium][MOLES] * TRITIUM_FUEL_POWER
		total_fuel_moles += moderator_input.gases[/datum/gas/antinoblium][MOLES] * ANTINOBLIUM_FUEL_POWER

		// Power modifier types: increases fuel effectiveness
		var/power_mod_moles = 0
		power_mod_moles += moderator_input.gases[/datum/gas/oxygen][MOLES] * OXYGEN_POWER_MOD
		power_mod_moles += moderator_input.gases[/datum/gas/hydrogen][MOLES] * HYDROGEN_POWER_MOD

		// Now make some actual power!
		if(total_fuel_moles >= minimum_coolant_level) //You at least need SOME fuel.
			var/fuel_power = max((total_fuel_moles * 10 / moderator_input.total_moles()), 1)
			var/power_modifier = max(power_mod_moles * 10 / moderator_input.total_moles(), 1) //You can never have negative IPM. For now.
			power_produced = max(0,((fuel_power*power_modifier)*moderator_input.total_moles())) / delta_time
			if(active)
				coolant_output.remove_specific(/datum/gas/pluoxium, total_fuel_moles/20) //Shove out pluoxium into the air when it's fuelled. You need to filter this off, or you're gonna have a bad time.

		// Control types: increases control of K
		var/total_control_moles = 0
		total_control_moles += moderator_input.gases[/datum/gas/nitrogen][MOLES] * NITROGEN_CONTROL_MOD
		total_control_moles += moderator_input.gases[/datum/gas/carbon_dioxide][MOLES]  * CARBON_CONTROL_MOD
		total_control_moles += moderator_input.gases[/datum/gas/pluoxium][MOLES]  * PLUOXIUM_CONTROL_MOD
		if(total_control_moles >= minimum_coolant_level)
			var/control_bonus = total_control_moles / REACTOR_CONTROL_FACTOR //1 mol of n2 -> 0.002 bonus control rod effectiveness, if you want a super controlled reaction, you'll have to sacrifice some power.
			control_rod_effectiveness = initial(control_rod_effectiveness) + control_bonus

		// Permeability types: increases cooling efficiency
		var/total_permeability_moles = 0
		total_permeability_moles += moderator_input.gases[/datum/gas/bz][MOLES] * BZ_PERMEABILITY_MOD
		total_permeability_moles += moderator_input.gases[/datum/gas/water_vapor][MOLES] * WATER_PERMEABILITY_MOD
		total_permeability_moles += moderator_input.gases[/datum/gas/hypernoblium][MOLES] * NOBLIUM_PERMEABILITY_MOD
		if(total_permeability_moles >= minimum_coolant_level)
			gas_absorption_effectiveness = clamp(gas_absorption_constant + (total_permeability_moles / REACTOR_PERMEABILITY_FACTOR), 0, 1)

		// Radiation types: increases radiation
		radioactivity_spice_multiplier += moderator_input.gases[/datum/gas/nitrogen][MOLES] * NITROGEN_RAD_MOD //An example setup of 50 moles of n2 (for dealing with spent fuel) leaves us with a radioactivity spice multiplier of 3.
		radioactivity_spice_multiplier += moderator_input.gases[/datum/gas/carbon_dioxide][MOLES] * CARBON_RAD_MOD
		radioactivity_spice_multiplier += moderator_input.gases[/datum/gas/hydrogen][MOLES] * HYDROGEN_RAD_MOD
		radioactivity_spice_multiplier += moderator_input.gases[/datum/gas/tritium][MOLES] * TRITIUM_RAD_MOD
		radioactivity_spice_multiplier += moderator_input.gases[/datum/gas/antinoblium][MOLES] * ANTINOBLIUM_RAD_MOD

		// Degradation types: degrades the fuel rods
		var/total_degradation_moles = moderator_input.gases[/datum/gas/miasma][MOLES] //Because it's quite hard to get.
		if(total_degradation_moles >= minimum_coolant_level) //I'll be nice.
			depletion_modifier += total_degradation_moles / 15 //Oops! All depletion. This causes your fuel rods to get SPICY.
			if(prob(total_degradation_moles)) // don't spam the sound so much please
				playsound(src, pick('sound/machines/sm/accent/normal/1.ogg','sound/machines/sm/accent/normal/2.ogg','sound/machines/sm/accent/normal/3.ogg','sound/machines/sm/accent/normal/4.ogg','sound/machines/sm/accent/normal/5.ogg'), 100, TRUE)

		//From this point onwards, we clear out the remaining gasses.
		moderator_input.remove_ratio(REACTOR_MODERATOR_DECAY_RATE) //Remove about 10% of the gases
		K += total_fuel_moles / 1000
	else // if there's not enough to do anything, just clear it
		moderator_input.garbage_collect()

	var/fuel_power = 0 //So that you can't magically generate K with your control rods.
	if(active)
		if(!has_fuel())  //Reactor must be fuelled and ready to go before we can heat it up.
			shut_down() // shut it down!!!
		else
			for(var/obj/item/fuel_rod/FR in fuel_rods)
				K += FR.fuel_power
				fuel_power += FR.fuel_power
				FR.deplete(depletion_modifier)
			radioactivity_spice_multiplier += fuel_power

	// Firstly, find the difference between the two numbers.
	var/difference = abs(K - desired_k)

	// Then, hit as much of that goal with our cooling per tick as we possibly can.
	difference = clamp(difference, 0, control_rod_effectiveness) //And we can't instantly zap the K to what we want, so let's zap as much of it as we can manage....
	if(difference > fuel_power && desired_k > K)
		investigate_log("Reactor does not have enough fuel to get [difference]. We have [fuel_power] fuel power.", INVESTIGATE_REACTOR)
		difference = fuel_power //Again, to stop you being able to run off of 1 fuel rod.

	// If K isn't what we want it to be, let's try to change that
	if(K != desired_k)
		if(desired_k > K)
			K += difference
		else if(desired_k < K)
			K -= difference
		if(last_user && current_desired_k != desired_k) // Tell admins about it if it's done by a player
			current_desired_k = desired_k
			message_admins("Reactor desired criticality set to [desired_k] by [ADMIN_LOOKUPFLW(last_user)] in [ADMIN_VERBOSEJMP(src)]")
			investigate_log("reactor desired criticality set to [desired_k] by [key_name(last_user)] at [AREACOORD(src)]", INVESTIGATE_REACTOR)

	// Now, clamp K and heat up the reactor based on it.
	K = clamp(K, 0, REACTOR_MAX_CRITICALITY)
	var/particle_chance = min(power * K, 1000)
	while(particle_chance >= 100)
		fire_nuclear_particle()
		particle_chance -= 100
	if(prob(particle_chance))
		fire_nuclear_particle()
	if(active && has_fuel())
		temperature += REACTOR_HEAT_FACTOR * delta_time * has_fuel() * ((REACTOR_HEAT_EXPONENT**K) - 1) // heating from K has to be exponential to make higher K more dangerous

	// Cooling time!
	var/input_moles = coolant_input.total_moles() //Firstly. Do we have enough moles of coolant?
	if(input_moles >= minimum_coolant_level)
		last_coolant_temperature = coolant_input.return_temperature()
		//Important thing to remember, once you slot in the fuel rods, this thing will not stop making heat, at least, not unless you can live to be thousands of years old which is when the spent fuel finally depletes fully.
		var/heat_delta = (last_coolant_temperature - temperature) * gas_absorption_effectiveness //Take in the gas as a cooled input, cool the reactor a bit. The optimum, 100% balanced reaction sits at K=1, coolant input temp of 200K / -73 celsius.
		var/coolant_heat_factor = coolant_input.heat_capacity() / (coolant_input.heat_capacity() + REACTOR_HEAT_CAPACITY + (REACTOR_ROD_HEAT_CAPACITY * has_fuel())) //What percent of the total heat capacity is in the coolant
		last_heat_delta = heat_delta
		temperature += heat_delta * coolant_heat_factor
		coolant_input.return_temperature(last_coolant_temperature - (heat_delta * (1 - coolant_heat_factor))) //Heat the coolant output gas that we just had pass through us.
		coolant_output.merge(coolant_input) //And now, shove the input into the output.
		coolant_input.garbage_collect() //Clear out anything left in the input gate.
		color = null

	// And finally, set our pressure.
	last_output_temperature = coolant_output.temperature()
	pressure = coolant_output.temperature()
	power = ((temperature / REACTOR_TEMPERATURE_CRITICAL)**3) * 100

	// Make some power!
	if(power_produced > 0)
		last_power_produced = power_produced
		last_power_produced *= (max(0,power)/100) //Aaaand here comes the cap. Hotter reactor => more power.
		last_power_produced *= base_power_modifier //Finally, we turn it into actual usable numbers.

	// Let's check if they're about to die, and let them know.
	handle_alerts(delta_time)
	update_icon()

	// Finally, our beautiful radiation!
	radiation_pulse(src, K*temperature*radioactivity_spice_multiplier*has_fuel()/(REACTOR_MAX_CRITICALITY*REACTOR_MAX_FUEL_RODS))

	// I FUCKING LOVE DATA!!!!!!
	kpaData += pressure
	if(kpaData.len > 100) //Only lets you track over a certain timeframe.
		kpaData.Cut(1, 2)
	powerData += last_power_produced //We scale up the figure for a consistent:tm: scale
	if(powerData.len > 100) //Only lets you track over a certain timeframe.
		powerData.Cut(1, 2)
	tempCoreData += temperature //We scale up the figure for a consistent:tm: scale
	if(tempCoreData.len > 100) //Only lets you track over a certain timeframe.
		tempCoreData.Cut(1, 2)
	tempInputData += last_coolant_temperature //We scale up the figure for a consistent:tm: scale
	if(tempInputData.len > 100) //Only lets you track over a certain timeframe.
		tempInputData.Cut(1, 2)
	tempOutputData += last_output_temperature //We scale up the figure for a consistent:tm: scale
	if(tempOutputData.len > 100) //Only lets you track over a certain timeframe.
		tempOutputData.Cut(1, 2)

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/has_fuel()
	return length(fuel_rods)

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/get_fuel_power()
	var/total_fuel_power = 0
	for(var/obj/item/fuel_rod/rod in fuel_rods)
		total_fuel_power += rod.fuel_power
	return total_fuel_power

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/relay(var/sound, var/message=null, loop = FALSE, channel = null) //Sends a sound + text message to the crew of a ship
	for(var/mob/M in GLOB.player_list)
		if(M.z == z)
			if(!isinspace(M))
				if(sound)
					if(channel) //Doing this forbids overlapping of sounds
						SEND_SOUND(M, sound(sound, repeat = loop, wait = 0, volume = 70, channel = channel))
					else
						SEND_SOUND(M, sound(sound, repeat = loop, wait = 0, volume = 70))
				if(message)
					to_chat(M, message)

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/stop_relay(channel) //Stops all playing sounds for crewmen on N channel.
	for(var/mob/M in GLOB.player_list)
		if(M.z == z)
			M.stop_sound_channel(channel)

//Method to handle sound effects, reactor warnings, all that jazz.
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/handle_alerts(delta_time)
	var/alert = FALSE //If we have an alert condition, we'd best let people know.

	//First alert condition: Overheat
	if(temperature >= REACTOR_TEMPERATURE_CRITICAL)
		alert = TRUE
		for(var/i in 1 to min((temperature-REACTOR_TEMPERATURE_CRITICAL)/100, 10))
			src.fire_nuclear_particle()
		if(temperature >= REACTOR_TEMPERATURE_MELTDOWN || prob(10))
			var/temp_damage = min(temperature/300, initial(vessel_integrity)/180) * delta_time	//3 minutes to meltdown from full integrity, worst-case.
			vessel_integrity -= temp_damage
	else if(temperature < 73) //That's as cold as I'm letting you get it, engineering.
		color = COLOR_CYAN
	else
		color = null

	//Second alert condition: Overpressurized (the more lethal one)
	if(pressure >= REACTOR_PRESSURE_CRITICAL)
		alert = TRUE
		Shake(6, 6, (delta_time/2) SECONDS)
		playsound(loc, 'sound/machines/clockcult/steam_whoosh.ogg', 100, TRUE)
		var/turf/T = get_turf(src)
		T.atmos_spawn_air("water_vapor=[pressure/100];TEMP=[temperature]")
		var/pressure_damage = min(pressure/300, initial(vessel_integrity)/180) * delta_time	//You get 60 seconds (if you had full integrity), worst-case. But hey, at least it can't be instantly nuked with a pipe-fire.. though it's still very difficult to save.
		vessel_integrity -= pressure_damage
		if(vessel_integrity <= 0) //It wouldn't be able to tank another hit.
			investigate_log("Reactor blowout at [pressure] kPa with desired criticality at [desired_k]", INVESTIGATE_REACTOR)
			blowout()
			return

	// Yikes, that's no good
	if(vessel_integrity <= 0)
		investigate_log("Reactor melted down at [temperature] kelvin with desired criticality at [desired_k]", INVESTIGATE_REACTOR)
		meltdown() //Oops! All meltdown
		return

	if(!alert) //Congrats! You stopped the meltdown / blowout.
		if(!next_warning)
			return // don't bother if the reactor wasn't in trouble
		stop_relay(RADIO_CHANNEL_ENGINEERING)
		next_warning = 0 // there's no next warning if the reactor is fine
		set_light(0)
		light_color = LIGHT_COLOR_CYAN
		set_light(10)
		var/msg = "Reactor returning to safe operating parameters."
		if(vessel_integrity <= 350)
			msg += " Maintenance required."
		msg += " Structural integrity: [get_integrity()]%."
		radio.talk_into(src, msg, engi_channel)
		if(evacuation_procedures)
			radio.talk_into(src, "Attention: Reactor has been stabilized. Please return to your workplaces.", crew_channel)
		evacuation_procedures = FALSE
		return

	if(world.time < next_warning) // we're not ready for another warning yet
		return

	next_warning = world.time + 30 SECONDS //To avoid engis pissing people off when reaaaally trying to stop the meltdown or whatever.

	if(get_integrity() < 40 && !evacuation_procedures)
		evacuation_procedures = TRUE
		radio.talk_into(src, "WARNING: Reactor failure imminent. Integrity: [get_integrity()]%", engi_channel)
		radio.talk_into(src, "Reactor failure imminent. Please remain calm and evacuate the facility immediately.", crew_channel)
		playsound(src, 'modular_zubbers/code/modules/power/agcnr/sounds/machines/reactor_alert_3.ogg', 100, extrarange=100, pressure_affected=FALSE, ignore_walls=TRUE)
		relay('modular_zubbers/code/modules/power/agcnr/sounds/effects/reactor/alarm.ogg', null, TRUE, channel = RADIO_CHANNEL_ENGINEERING)
	else if(get_integrity() < 95)
		radio.talk_into(src, "WARNING: Reactor structural integrity faltering. Integrity: [get_integrity()]%", engi_channel)
		playsound(src, 'modular_zubbers/code/modules/power/agcnr/sounds/machines/reactor_alert_1.ogg', 75, extrarange=50, pressure_affected=FALSE, ignore_walls=TRUE)

	set_light(0)
	light_color = "#FF0000"
	set_light(10)

	//PANIC


//Failure condition 1: Meltdown. Achieved by having heat go over tolerances. This is less devastating because it's easier to achieve.
//Results: Engineering becomes unusable and your engine irreparable
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/meltdown()
	set waitfor = FALSE
	SSair.atmos_machinery -= src //Annd we're now just a useless brick.
	vessel_integrity = null // this makes it show up weird on the monitor to even further emphasize something's gone horribly wrong
	slagged = TRUE
	color = null
	update_icon()
	STOP_PROCESSING(SSmachines, src)
	icon_state = "reactor_slagged"
	radiation_pulse(src, 40, 5)
	var/obj/effect/landmark/nuclear_waste_spawner/NSW = new /obj/effect/landmark/nuclear_waste_spawner/strong(get_turf(src))
	relay('modular_zubbers/code/modules/power/agcnr/sounds/effects/reactor/meltdown.ogg', "<span class='userdanger'>You hear a horrible metallic hissing.</span>")
	stop_relay(RADIO_CHANNEL_ENGINEERING)
	NSW.fire() //This will take out engineering for a decent amount of time as they have to clean up the sludge.
	for(var/obj/machinery/power/apc/apc in SSmachines.get_machines_by_type(/obj/machinery/power/apc))
		if((apc.z == z) && prob(70))
			apc.overload_lighting()
	var/datum/gas_mixture/coolant_input = airs[COOLANT_INPUT_GATE]
	var/datum/gas_mixture/moderator_input = airs[MODERATOR_INPUT_GATE]
	var/datum/gas_mixture/coolant_output = airs[COOLANT_OUTPUT_GATE]
	var/turf/T = get_turf(src)
	coolant_input.return_temperature(temperature*2)
	moderator_input.return_temperature(temperature*2)
	coolant_output.return_temperature(temperature*2)
	T.assume_air(coolant_input)
	T.assume_air(moderator_input)
	T.assume_air(coolant_output)
	explosion(get_turf(src), 0, 5, 10, 20, TRUE, TRUE)

//Failure condition 2: Blowout. Achieved by reactor going over-pressured. This is a round-ender because it requires more fuckery to achieve.
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/blowout()
	explosion(get_turf(src), GLOB.MAX_EX_DEVESTATION_RANGE, GLOB.MAX_EX_HEAVY_RANGE, GLOB.MAX_EX_LIGHT_RANGE, GLOB.MAX_EX_FLASH_RANGE)
	meltdown() //Double kill.
	relay('modular_zubbers/code/modules/power/agcnr/sounds/effects/reactor/explode.ogg')
	SSweather.run_weather("nuclear fallout")
	for(var/X in GLOB.landmarks_list)
		if(istype(X, /obj/effect/landmark/nuclear_waste_spawner))
			var/obj/effect/landmark/nuclear_waste_spawner/WS = X
			if(is_station_level(WS.z)) //Begin the SLUDGING
				WS.range *= 3
				WS.fire()

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/update_icon(updates=ALL)
	. = ..()
	icon_state = "reactor_off"
	switch(temperature)
		if(0 to REACTOR_TEMPERATURE_MINIMUM)
			icon_state = "reactor_on"
		if(REACTOR_TEMPERATURE_MINIMUM to REACTOR_TEMPERATURE_OPERATING)
			icon_state = "reactor_hot"
		if(REACTOR_TEMPERATURE_OPERATING to REACTOR_TEMPERATURE_CRITICAL)
			icon_state = "reactor_veryhot"
		if(REACTOR_TEMPERATURE_CRITICAL to REACTOR_TEMPERATURE_MELTDOWN) //Point of no return.
			icon_state = "reactor_overheat"
		if(REACTOR_TEMPERATURE_MELTDOWN to INFINITY)
			icon_state = "reactor_meltdown"
	if(!has_fuel())
		icon_state = "reactor_off"
	if(slagged)
		icon_state = "reactor_slagged"

//Startup, shutdown

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/start_up()
	START_PROCESSING(SSmachines, src)
	desired_k = 1
	active = TRUE
	set_light(10)
	var/startup_sound = pick('modular_zubbers/code/modules/power/agcnr/sounds/effects/reactor/startup.ogg', 'modular_zubbers/code/modules/power/agcnr/sounds/effects/reactor/startup2.ogg')
	playsound(loc, startup_sound, 100)
	update_parents() // double-check all the pipes are connected on startup


//Shuts off the fuel rods, ambience, etc. Keep in mind that your temperature may still go up!
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/shut_down()
	STOP_PROCESSING(SSmachines, src)
	set_light(0)
	K = 0
	desired_k = 0
	power = 0
	active = FALSE
	update_icon()

/obj/effect/decal/nuclear_waste/Initialize(mapload)
	. = ..()
	for(var/obj/A in get_turf(src))
		if(istype(A, /obj/structure))
			qdel(src) //It is more processing efficient to do this here rather than when searching for available turfs.
	set_light(1)
	START_PROCESSING(SSobj, src)

/obj/effect/decal/nuclear_waste/process(delta_time)
	if(prob(10)) // woah there, don't overload the radiation subsystem
		radiation_pulse(src, 30)

/obj/effect/decal/nuclear_waste/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/landmark/nuclear_waste_spawner //Clean way of spawning nuclear gunk after a reactor core meltdown.
	name = "Nuclear waste spawner"
	var/range = 15 //15 tile radius to spawn goop

/obj/effect/landmark/nuclear_waste_spawner/strong
	range = 30

/obj/effect/landmark/nuclear_waste_spawner/proc/fire()
	for(var/turf/open/floor in orange(range, get_turf(src)))
		if(prob(35)) //Scatter the sludge, don't smear it everywhere
			new /obj/effect/decal/nuclear_waste (floor)
	qdel(src)

/obj/effect/decal/nuclear_waste/attackby(obj/item/tool, mob/user)
	if(tool.tool_behaviour == TOOL_SHOVEL)
		to_chat(user, span_notice("You start to clear [src]..."))
		if(tool.use_tool(src, user, 50, volume=100))
			radiation_pulse(src, 40, 5) //MORE RADS
			to_chat(user, span_notice("You clear [src]. "))
			qdel(src)
			return
	. = ..()

/area/engineering/main/reactor_core
	name = "Nuclear Reactor Core"

/area/engineering/main/reactor_control
	name = "Reactor Control Room"

/obj/item/sealant
	name = "Flexi seal"
	desc = "A neat spray can that can repair torn inflatable segments, and more!"
	icon = 'icons/obj/maintenance_loot.dmi'
	icon_state = "lead_pipe"
	w_class = WEIGHT_CLASS_TINY


