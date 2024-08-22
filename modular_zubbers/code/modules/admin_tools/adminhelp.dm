/client/var/datum/admin_help/selected_ticket //the current ticket being viewed in the Tickets Panel (usually) admin/mentor client

/datum/admin_help/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	var/list/tickets = list()

	var/selected_ticket = null

	if(user.client.selected_ticket)
		var/datum/admin_help/ticket = user.client.selected_ticket
		selected_ticket = list(
			"id" = ticket.id,
			"name" = ticket.LinkedReplyName(),
			"state" = (ticket.state),
			"level" = null,
			"handler" = ticket.handler,
			"opened_at" = (world.time - ticket.opened_at),
			"closed_at" = (world.time - ticket.closed_at),
			"opened_at_date" = gameTimestamp(wtime = ticket.opened_at),
			"closed_at_date" = gameTimestamp(wtime = ticket.closed_at),
			"actions" = ticket.FullMonty(),
			"log" = null,
		)

	for(var/datum/admin_help/ticket as anything in GLOB.ahelp_tickets.active_tickets)
		if(user.client.holder)
			tickets.Add(list(list(
				"id" = ticket.id,
				"name" = ticket.initiator_key_name,
				"state" = (ticket.state),
				"level" = null,
				"handler" = ticket.handler,
				"opened_at" = (world.time - ticket.opened_at),
				"closed_at" = (world.time - ticket.closed_at),
				"opened_at_date" = gameTimestamp(wtime = ticket.opened_at),
				"closed_at_date" = gameTimestamp(wtime = ticket.closed_at),
			)))

	data["tickets"] = tickets

	data["selected_ticket"] = selected_ticket

	return data

/datum/admin_help/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("new_ticket")
			var/list/ckeys = list()
			for(var/client/C in GLOB.clients)
				ckeys += C.key

			var/ckey = lowertext(tgui_input_list(usr, "Please select the ckey of the user.", "Select CKEY", ckeys))
			if(!ckey)
				return

			var/client/player
			for(var/client/C in GLOB.clients)
				if(C.ckey == ckey)
					player = C

			if(!player)
				to_chat(usr, "<span class='warning'>Ckey ([ckey]) not online.</span>")
				return

			var/ticket_text = tgui_input_text(usr, "What should the initial text be?", "New Ticket")
			if(!ticket_text)
				to_chat(usr, "<span class='warning'>Ticket message cannot be empty.</span>")
				return

			var/level = tgui_alert(usr, "Is this ticket Admin-Level or Mentor-Level?", "Ticket Level", list("Admin", "Mentor"))
			if(!level)
				return

			if(player.current_ticket)
				if(tgui_alert(usr, "The player already has a ticket open. Is this for the same issue?","Duplicate?",list("Yes","No")) != "No")
					if(player.current_ticket)
						to_chat(usr, "<span class='adminnotice'>PM to-<b>Admins</b>: [ticket_text]</span>")
						return
					else
						to_chat(usr, "<span class='warning'>Ticket not found, creating new one...</span>")
/*
		if("pick_ticket")
			var/datum/admin_help/ticket = ID2Ticket(params["ticket_id"])
			usr.client.selected_ticket = ticket
			. = TRUE
		if("retitle_ticket")
			usr.client.selected_ticket.Retitle()
			. = TRUE
		if("reopen_ticket")
			usr.client.selected_ticket.Reopen()
			. = TRUE
		if("undock_ticket")
			usr.client.selected_ticket.tgui_interact(usr)
			usr.client.selected_ticket = null
			. = TRUE */
		if("send_msg")
			if(!params["msg"])
				return

			usr.client.cmd_admin_pm(usr.client.selected_ticket.handler, sanitize(params["msg"]), usr.client.selected_ticket)
			. = TRUE
