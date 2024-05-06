#define DAM_SCALE_FACTOR 0.01
#define METAL_PER_TICK 100
#define MAT_STEEL "iron"

/datum/species/protean
	name = "Protean"
	id = SPECIES_PROTEAN
	//death_message = "rapidly loses cohesion, dissolving into a cloud of gray dust..."
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
	//knockout_message = "collapses inwards, forming a disordered puddle of gray goo."
	/// damage to blob
	var/damage_to_blob = 100
	bodytemp_normal = 290
	siemens_coeff = 1.1 // Changed in accordance to the 'what to do now' section of the rework document
	mutant_organs = list(/obj/item/organ/internal/nano/orchestrator, /obj/item/organ/internal/nano/refactory)
	mutantbrain = /obj/item/mmi/posibrain/nano
	mutantappendix = null
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/nano,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/nano,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/nano,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/nano,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/nano,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/nano,
	)

	var/global/list/protean_abilities = list()

	var/monochromatic = FALSE //IGNORE ME

/datum/species/protean/New()
	..()
	//if(!LAZYLEN(protean_abilities))
		//var/list/powertypes = subtypesof(/obj/effect/protean_ability)
		//for(var/path in powertypes)
			//protean_abilities += new path()

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

/mob/living/carbon/human/protean/get_status_tab_items()
	var/obj/item/organ/internal/nano/refactory/refactory = locate() in usr.get_organs_for_zone(CHEST)
	if(refactory)
		. +=("- -- --- Refactory Metal Storage --- -- -")
		var/max = refactory.max_storage
		for(var/material in refactory.stored_materials)
			var/amount = refactory.get_stored_material(material)
			. +=("[capitalize(material)], [amount]/[max]")
	else
		. += ("- -- --- REFACTORY ERROR! --- -- -")


// Various modifiers
/datum/modifier/protean
	var/material_use = METAL_PER_TICK
	var/material_name = MAT_STEEL

/datum/modifier/protean/steel
	material_name = MAT_STEEL
	material_use = METAL_PER_TICK / 5		// 5 times weaker

/datum/modifier/protean/steel/process()
	. = ..()
	var/dt = 2	// put it on param sometime but for now assume 2
	var/mob/living/carbon/human/Human = usr
	var/heal = 1 * dt
	var/brute_heal_left = max(0, heal - Human.getBruteLoss())
	var/burn_heal_left = max(0, heal - Human.getFireLoss())

	// I didn't want to constantly rebuild and lose my markings to stop being an unknown
	Human.adjustBruteLoss(-brute_heal_left)
	Human.adjustFireLoss(-burn_heal_left)
	Human.adjustToxLoss(-3.6)


/proc/protean_requires_healing(mob/living/carbon/human/Human)
	if(!istype(Human))
		return FALSE
	return Human.getBruteLoss() || Human.getFireLoss() || Human.getToxLoss()

/mob/living/carbon/human/proc/rig_transform()
	set name = "Modify Form - Hardsuit"
	set desc = "Allows a protean to solidify its form into one extremely similar to a hardsuit."
	set category = "Abilities"

	if(istype(loc, /obj/item/hardsuit/protean))
		var/obj/item/hardsuit/protean/prig = loc
		src.forceMove(get_turf(prig))
		prig.forceMove(src)
		return

	if(isturf(loc))
		var/obj/item/hardsuit/protean/prig = locate() in contents
		if(prig)
			prig.forceMove(get_turf(src))
			src.forceMove(prig)
			return

/mob/living/carbon/human/proc/rig_self()
	set name = "Deploy Nanosuit To Self"
	set desc = "Deploy a light nanocluster RIGsuit around yourself."
	set category = "Abilities"

	if(istype(back, /obj/item/hardsuit/protean))
		var/obj/item/hardsuit/protean/suit = back
		if(suit.myprotean == src)
			suit.forceMove(src)
			to_chat(src, span_warning("You retract your nanosuit."))
			return

	for(var/obj/item/hardsuit/protean/suit in contents)
		//usr.force_equip_item(src, /datum/inventory_slot_meta/inventory/back, suit)
		to_chat(src, span_warning("You deploy your nanosuit."))
		return

	to_chat(src, span_warning("You don't have a nanocluster RIG. Somehow."))

/datum/species/protean/get_species_description()
	return "Sometimes very advanced civilizations will produce the ability to swap into manufactured, robotic bodies. And sometimes \
			<i>very</i> advanced civilizations have the option of 'nanoswarm' bodies. Effectively a single robot body comprised \
			of millions of tiny nanites working in concert to maintain cohesion."

#undef DAM_SCALE_FACTOR
#undef METAL_PER_TICK
