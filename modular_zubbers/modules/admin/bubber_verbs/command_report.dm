/client/proc/create_command_shift_report()

	set name = "Create Command Roundstart Report"
	set category = "Admin.Events"

	if(!holder || !check_rights(R_FUN))
		return
	var/created_report = 0

	if(created_report == 1)
		message_admins("Station goal and report was already issued!")
		return
	if(created_report == 0)
		var/datum/command_report/report = new /datum/command_report
		report.send_trait_report()
		message_admins("[key_name_admin(holder)] created Roundstart Command Report")
		log_admin("[key_name_admin(holder)] created Roundstart Command Report")
		created_report = 1
		return created_report

/datum/command_report/proc/send_trait_report()
	. = "<b><i>Central Command Status Summary</i></b><hr>"

	SSstation.generate_station_goals()

	if(!length(SSstation.get_station_goals()))
		. = "<hr><b>No assigned goals.</b><BR>"
	else
		. += generate_station_goal_report()
	if(!SSstation.station_traits.len)
		. = "<hr><b>No identified shift divergencies.</b><BR>"
	else
		. += generate_station_trait_report()

	. += "<hr>This concludes your shift-start evaluation. Have a secure shift!<hr>\
	<p style=\"color: grey; text-align: justify;\">This label certifies an Intern has reviewed the above before sending. This document is the property of Nanotrasen Corporation.</p>"

	print_command_report(., "Central Command Status Summary", announce = FALSE)
	priority_announce("Hello, crew of [station_name()]. Our intern has finished their shift-start divergency and goals evaluation, which has been sent to your communications console. Have a secure shift!", "Divergency Report", SSstation.announcer.get_rand_report_sound())

/*
 * Generate a list of station goals available to purchase to report to the crew.
 *
 * Returns a formatted string all station goals that are available to the station.
 */
/datum/command_report/proc/generate_station_goal_report()
	if(!length(SSstation.get_station_goals()))
		return
	. = "<hr><b>Special Orders for [station_name()]:</b><BR>"
	var/list/goal_reports = list()
	for(var/datum/station_goal/station_goal as anything in SSstation.get_station_goals())
		station_goal.on_report()
		goal_reports += station_goal.get_report()

	. += goal_reports.Join("<hr>")
	return

/*
 * Generate a list of active station traits to report to the crew.
 *
 * Returns a formatted string of all station traits (that are shown) affecting the station.
 */
/datum/command_report/proc/generate_station_trait_report()
	var/trait_list_string = ""
	for(var/datum/station_trait/station_trait as anything in SSstation.station_traits)
		if(!station_trait.show_in_report)
			continue
		trait_list_string += "[station_trait.get_report()]<BR>"
	if(trait_list_string != "")
		return "<hr><b>Identified shift divergencies:</b><BR>" + trait_list_string
	return
