/obj/item/deepcore_upgrade
	name = "Polytrinic non magnetic asteroid arrestor upgrade"
	desc = "A component which, when slotted into an asteroid magnet computer, will allow it to capture increasingly valuable asteroids."
	icon = 'modular_zubbers/icons/obj/machines/scanners.dmi'
	icon_state = "minescanner_upgrade"
	var/tier = 2

/obj/item/deepcore_upgrade/max
	name = "Phasic asteroid arrestor upgrade"
	icon_state = "minescanner_upgrade_max"
	tier = 3

/obj/item/mining_sensor_upgrade
	name = "Dradis mineral sensor upgrade (tier II)"
	desc = "A component which, when slotted into an asteroid magnet computer, will allow it to capture increasingly valuable asteroids."
	icon = 'modular_zubbers/icons/obj/machines/scanners.dmi'
	icon_state = "minesensor"
	var/tier = 2

/obj/item/mining_sensor_upgrade/max
	name = "Dradis mineral sensor upgrade (tier III)"
	icon_state = "minesensor_max"
	tier = 3


/datum/techweb_node/mineral_nonferrous
	id = "mineral_nonferrous"
	display_name = "Polytrinic asteroid mining equipment"
	description = "Upgrades for the mining ship's asteroid arrestor and dradis console, allowing it to detect and lock on to more specific mineral compositions in asteroid cores."
	prereq_ids = list("base")
	design_ids = list("deepcore1", "asteroidscanner")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)

/datum/techweb_node/mineral_exotic
	id = "mineral_exotic"
	display_name = "Phasic asteroid mining equipment"
	description = "Advanced arrestor and dradis console upgrade for the mining ship, allowing it to handle any asteroid with a mineral composition at it's core."
	prereq_ids = list("mineral_nonferrous")
	design_ids = list("deepcore2", "asteroidscanner2")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 12500)

/datum/design/deepcore1
	name = "Polytrinic non magnetic asteroid arrestor upgrade"
	desc = "An upgrade module for the mining ship's asteroid arrestor, allowing it to lock on to asteroids containing valuable non ferrous metals such as gold, silver, copper and plasma"
	id = "deepcore1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000,/datum/material/titanium = 25000, /datum/material/silver = 5000)
	build_path = /obj/item/deepcore_upgrade
	category = list("Asteroid Mining")
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/deepcore2
	name = "Phasic asteroid arrestor upgrade"
	desc = "An upgrade module for the mining ship's asteroid arrestor, allowing it to lock on to asteroids containing rare and valuable minerals such as diamond, uranium and the exceedingly rare bluespace crystals."
	id = "deepcore2"
	build_type = PROTOLATHE
	materials = list(/datum/material/titanium = 25000, /datum/material/gold = 10000, /datum/material/silver = 10000, /datum/material/plasma = 10000, /datum/material/uranium = 5000, /datum/material/diamond = 5000)
	build_path = /obj/item/deepcore_upgrade/max
	category = list("Asteroid Mining")
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/asteroidscannert2
	name = "Tier II asteroid sensor module"
	desc = "An upgrade for dradis computers, allowing them to scan for asteroids containing valuable non ferrous metals such as gold, silver, copper and plasma"
	id = "asteroidscanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000,/datum/material/titanium = 5000, /datum/material/silver = 2000)
	build_path = /obj/item/mining_sensor_upgrade
	category = list("Asteroid Mining")
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/asteroidscannert3
	name = "Tier III asteroid sensor module"
	desc = "An upgrade for dradis computers, allowing them to scan for asteroids containing rare and valuable minerals such as diamond, uranium and the exceedingly rare bluespace crystals."
	id = "asteroidscanner2"
	build_type = PROTOLATHE
	materials = list(/datum/material/titanium = 25000, /datum/material/plasma = 2000, /datum/material/uranium = 2000, /datum/material/diamond = 2000)
	build_path = /obj/item/mining_sensor_upgrade/max
	category = list("Asteroid Mining")
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE
