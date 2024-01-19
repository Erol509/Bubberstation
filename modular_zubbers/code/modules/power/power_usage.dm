/obj/machinery/proc/change_power_consumption(new_power_consumption, use_power_mode = POWER_USE_IDLE)
	var/old_power
	switch(use_power_mode)
		if(IDLE_POWER_USE)
			old_power = idle_power_usage
			idle_power_usage = new_power_consumption
		if(ACTIVE_POWER_USE)
			old_power = active_power_usage
			active_power_usage = new_power_consumption
		else
			return
