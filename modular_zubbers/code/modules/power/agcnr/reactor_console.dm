//Controlling the reactor.

/obj/machinery/computer/reactor
	name = "reactor control console"
	desc = "A computer which monitors and controls a reactor"
	light_color = "#55BA55"
	light_power = 1
	light_range = 3
	icon_state = "oldcomp"
	icon_screen = "oldcomp_broken"
	icon_keyboard = null
	circuit = /obj/item/circuitboard/computer/reactor // we have the technology
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/reactor = null
	var/id = null
	var/next_stat_interval = 0

/obj/machinery/computer/reactor/multitool_act(mob/living/user, obj/item/multitool/I)
	if(isnull(id) || isnum(id))
		var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/N = I.buffer
		if(!istype(N))
			user.balloon_alert(user, "invalid reactor ID!")
			return TRUE
		reactor = N
		id = N.id
		user.balloon_alert(user, "linked!")
		return TRUE
	return ..()

/obj/machinery/computer/reactor/preset
	id = "default_reactor_for_lazy_mappers"

/obj/item/circuitboard/computer/reactor
	name = "Reactor Control (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/reactor

/obj/machinery/computer/reactor/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/reactor/LateInitialize()
	. = ..()
	link_to_reactor()

/obj/machinery/computer/reactor/attack_hand(mob/living/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/reactor/ui_interact(mob/user, datum/tgui/ui)
	..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ReactorComputer")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/reactor/ui_act(action, params)
	if(..())
		return
	if(!reactor)
		return
	switch(action)
		if("power")
			if(reactor.active)
				if(reactor.K <= 0 && reactor.temperature <= REACTOR_TEMPERATURE_MINIMUM)
					reactor.shut_down()
			else if(reactor.fuel_rods.len)
				reactor.start_up()
				message_admins("Reactor started up by [ADMIN_LOOKUPFLW(usr)] in [ADMIN_VERBOSEJMP(src)]")
				investigate_log("Reactor started by [key_name(usr)] at [AREACOORD(src)]", INVESTIGATE_REACTOR)
		if("input")
			var/input = text2num(params["target"])
			reactor.last_user = usr
			reactor.desired_k = reactor.active ? clamp(input, 0, REACTOR_MAX_CRITICALITY) : 0
		if("eject")
			if(reactor?.temperature > REACTOR_TEMPERATURE_MINIMUM)
				return
			if(reactor?.slagged)
				return
			var/rod_index = text2num(params["rod_index"])
			if(rod_index < 1 || rod_index > reactor.fuel_rods.len)
				return
			var/obj/item/fuel_rod/rod = reactor.fuel_rods[rod_index]
			if(!rod)
				return
			playsound(src, pick('modular_zubbers/code/modules/power/agcnr/sounds/effects/reactor/switch.ogg','modular_zubbers/code/modules/power/agcnr/sounds/effects/reactor/switch2.ogg','modular_zubbers/code/modules/power/agcnr/sounds/effects/reactor/switch3.ogg'), 100, FALSE)
			playsound(reactor, 'modular_zubbers/code/modules/power/agcnr/sounds/effects/reactor/crane_1.wav', 100, FALSE)
			rod.forceMove(get_turf(reactor))
			reactor.fuel_rods.Remove(rod)

/obj/machinery/computer/reactor/ui_data(mob/user)
	var/list/data = list()
	data["control_rods"] = 0
	data["k"] = 0
	data["desiredK"] = 0
	if(reactor)
		data["k"] = reactor.K
		data["desiredK"] = reactor.desired_k
		data["control_rods"] = 100 - (100 * reactor.desired_k / REACTOR_MAX_CRITICALITY) //Rod insertion is extrapolated as a function of the percentage of K
		data["integrity"] = reactor.get_integrity()
	data["powerData"] = reactor ? reactor.powerData : list()
	data["kpaData"] = reactor ? reactor.kpaData : list()
	data["tempCoreData"] = reactor ? reactor.tempCoreData : list()
	data["tempInputData"] = reactor ? reactor.tempInputData : list()
	data["tempOutputData"] = reactor ? reactor.tempOutputData : list()
	data["coreTemp"] = reactor ? round(reactor.temperature) : 0
	data["coolantInput"] = reactor ? round(reactor.last_coolant_temperature) : T20C
	data["coolantOutput"] = reactor ? round(reactor.last_output_temperature) : T20C
	data["power"] = reactor ? reactor.last_power_produced : 0
	data["kpa"] = reactor ? reactor.pressure : 0
	data["active"] = reactor ? reactor.active : FALSE
	data["shutdownTemp"] = REACTOR_TEMPERATURE_MINIMUM
	var/list/rod_data = list()
	if(reactor)
		var/cur_index = 0
		for(var/obj/item/fuel_rod/rod in reactor.fuel_rods)
			cur_index++
			rod_data.Add(
				list(
					"name" = rod.name,
					"depletion" = rod.depletion,
					"rod_index" = cur_index
				)
			)
	data["rods"] = rod_data
	return data

/obj/machinery/computer/reactor/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, span_notice("You start [anchored ? "un" : ""]securing [name]..."))
	if(I.use_tool(src, user, 40, volume=75))
		to_chat(user, span_notice("You [anchored ? "un" : ""]secure [name]."))
		set_anchored(!anchored)
		return TRUE
	return FALSE

/obj/machinery/computer/reactor/proc/link_to_reactor()
	for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/asdf in SSmachines.get_all_machines())
		if(asdf.id && asdf.id == id)
			reactor = asdf
			return TRUE
	return FALSE

#define FREQ_REACTOR_CONTROL 1439.69

//Preset pumps for mappers. You can also set the id tags yourself.
/obj/machinery/atmospherics/components/binary/pump/reactor_input
	id_tag = "reactor_input"

/obj/machinery/atmospherics/components/binary/pump/reactor_output
	id_tag = "reactor_output"

/obj/machinery/atmospherics/components/binary/pump/reactor_moderator
	id_tag = "reactor_moderator"

/obj/machinery/computer/reactor/pump
	name = "Reactor inlet valve computer"
	desc = "A computer which controls valve settings on an advanced gas cooled reactor. Alt click it to remotely set pump pressure."
	icon_screen = "reactor_input"
	id = "reactor_input"
	var/datum/radio_frequency/radio_connection
	var/on = FALSE

/obj/machinery/computer/reactor/pump/AltClick(mob/user)
	. = ..()
	var/newPressure = input(user, "Set new output pressure (kPa)", "Remote pump control", null) as num
	if(!newPressure)
		return
	newPressure = clamp(newPressure, 0, MAX_OUTPUT_PRESSURE) //Number sanitization is not handled in the pumps themselves, only during their ui_act which this doesn't use.
	signal(on, newPressure)

/obj/machinery/computer/reactor/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/reactor/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/reactor/pump/attack_hand(mob/living/user)
	. = ..()
	if(!is_operational)
		return FALSE
	playsound(loc, pick('modular_zubbers/code/modules/power/agcnr/sounds/effects/reactor/switch.ogg','modular_zubbers/code/modules/power/agcnr/sounds/effects/reactor/switch2.ogg','modular_zubbers/code/modules/power/agcnr/sounds/effects/reactor/switch3.ogg'), 100, FALSE)
	visible_message(span_notice("[src]'s switch flips [on ? "off" : "on"]."))
	on = !on
	signal(on)

/obj/machinery/computer/reactor/pump/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	radio_connection = SSradio.add_object(src, FREQ_REACTOR_CONTROL,filter=RADIO_CHANNEL_ENGINEERING)

/obj/machinery/computer/reactor/pump/proc/signal(power, set_output_pressure=null)
	var/datum/signal/signal
	if(!set_output_pressure) //Yes this is stupid, but technically if you pass through "set_output_pressure" onto the signal, it'll always try and set its output pressure and yeahhh...
		signal = new(list(
			"tag" = id,
			"frequency" = FREQ_REACTOR_CONTROL,
			"timestamp" = world.time,
			"power" = power,
			"sigtype" = "command"
		))
	else
		signal = new(list(
			"tag" = id,
			"frequency" = FREQ_REACTOR_CONTROL,
			"timestamp" = world.time,
			"power" = power,
			"set_output_pressure" = set_output_pressure,
			"sigtype" = "command"
		))
	radio_connection.post_signal(src, signal, filter=RADIO_CHANNEL_ENGINEERING)

//Preset subtypes for mappers
/obj/machinery/computer/reactor/pump/reactor_input
	name = "Reactor inlet valve computer"
	icon_screen = "reactor_input"
	id = "reactor_input"

/obj/machinery/computer/reactor/pump/reactor_output
	name = "Reactor output valve computer"
	icon_screen = "reactor_output"
	id = "reactor_output"

/obj/machinery/computer/reactor/pump/reactor_moderator
	name = "Reactor moderator valve computer"
	icon_screen = "reactor_moderator"
	id = "reactor_moderator"
