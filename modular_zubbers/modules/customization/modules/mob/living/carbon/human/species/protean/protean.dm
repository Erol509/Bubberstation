#define DAM_SCALE_FACTOR 0.01
#define METAL_PER_TICK 100
#define MAT_STEEL "iron"

/datum/species/protean
	name = "Protean"
	id = SPECIES_PROTEAN
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
		TRAIT_RADIMMUNE,
		TRAIT_NOBREATH,
		TRAIT_TOXIMMUNE,
		TRAIT_GENELESS,
		TRAIT_NO_HUSK,
		TRAIT_OXYIMMUNE,
	)
	bodytemp_normal = 290
	siemens_coeff = 1.1
	mutant_organs = list(/obj/item/organ/internal/nano/orchestrator, /obj/item/organ/internal/nano/refactory)
	mutantbrain = /obj/item/mmi/posibrain/nano
	mutantappendix = null
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/protean,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/protean,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/protean,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/protean,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/protean,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/protean,
	)

	var/global/list/protean_abilities = list()

	var/monochromatic = FALSE //IGNORE ME

/datum/species/protean/New()
	..()

/datum/species/protean/randomize_features()
	var/list/features = ..()
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of mostly coldish, animal, matching colors
	switch(random)
		if(1)
			main_color = "#BBAA88"
			second_color = "#AAAA99"
		if(2)
			main_color = "#777766"
			second_color = "#888877"
		if(3)
			main_color = "#AA9988"
			second_color = "#AAAA99"
		if(4)
			main_color = "#EEEEDD"
			second_color = "#FFEEEE"
		if(5)
			main_color = "#DDCC99"
			second_color = "#DDCCAA"
	features["mcolor"] = main_color
	features["mcolor2"] = second_color
	features["mcolor3"] = second_color
	return features

/datum/species/protean/get_species_description()
	return "Sometimes very advanced civilizations will produce the ability to swap into manufactured, robotic bodies. And sometimes \
			<i>very</i> advanced civilizations have the option of 'nanoswarm' bodies. Effectively a single robot body comprised \
			of millions of tiny nanites working in concert to maintain cohesion."

#undef DAM_SCALE_FACTOR
#undef METAL_PER_TICK
