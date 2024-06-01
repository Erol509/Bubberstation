#define METAL_PER_TICK 100

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
	mutant_organs = list(/obj/item/organ/internal/orchestrator/protean, /obj/item/organ/internal/refactory/protean)
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


/datum/species/protean/New()
	..()

/datum/species/protean/get_species_description()
	return "Sometimes very advanced civilizations will produce the ability to swap into manufactured, robotic bodies. And sometimes \
			<i>very</i> advanced civilizations have the option of 'nanoswarm' bodies. Effectively a single robot body comprised \
			of millions of tiny nanites working in concert to maintain cohesion."

#undef METAL_PER_TICK
