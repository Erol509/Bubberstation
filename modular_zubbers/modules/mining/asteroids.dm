/obj/structure/asteroid
	name = "Asteroid (Ferrous)"
	var/list/core_composition = list(/turf/closed/mineral/iron, /turf/closed/mineral/titanium)

/obj/structure/asteroid/medium
	name = "Asteroid (Non Ferrous)"
	core_composition = list(/turf/closed/mineral/iron, /turf/closed/mineral/silver, /turf/closed/mineral/gold, /turf/closed/mineral/plasma)

/obj/structure/asteroid/large
	name = "Asteroid (Exotic Composition)"
	core_composition = list(/turf/closed/mineral/diamond, /turf/closed/mineral/uranium, /turf/closed/mineral/bscrystal)
