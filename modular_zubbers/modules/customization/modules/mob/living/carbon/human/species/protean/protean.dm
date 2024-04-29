#define DAM_SCALE_FACTOR 0.01
#define METAL_PER_TICK 100
#define MAT_STEEL "iron"

/datum/species/protean
	name = "Protean"
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
	mutantbrain  = /obj/item/mmi/posibrain/nano
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/organ/external/head/unbreakable/nano,
		BODY_ZONE_CHEST = /obj/item/organ/external/chest/unbreakable/nano,
		BODY_ZONE_L_ARM = /obj/item/organ/external/arm/unbreakable/nano,
		BODY_ZONE_R_ARM = /obj/item/organ/external/arm/right/unbreakable/nano,
		BODY_ZONE_L_LEG = /obj/item/organ/external/leg/unbreakable/nano,
		BODY_ZONE_R_LEG = /obj/item/organ/external/leg/right/unbreakable/nano,
	)

	var/global/list/protean_abilities = list()

	var/monochromatic = FALSE //IGNORE ME

/datum/species/protean/New()
	..()
	if(!LAZYLEN(protean_abilities))
		var/list/powertypes = subtypesof(/obj/effect/protean_ability)
		for(var/path in powertypes)
			protean_abilities += new path()
/*
/datum/species/protean/create_organs(var/mob/living/carbon/human/H)
	var/obj/item/nif/saved_nif = H.nif
	if(saved_nif)
		H.nif.unimplant(H) //Needs reference to owner to unimplant right.
		H.nif.moveToNullspace()
	..()
	if(saved_nif)
		saved_nif.quick_implant(H)

/datum/species/protean/get_effective_bodytype(mob/living/carbon/human/H, obj/item/I, slot_id)
	if(H)
		return H.impersonate_bodytype || ..()
	return ..()

/datum/species/protean/get_bodytype_legacy(var/mob/living/carbon/human/H)
	if(H)
		return H.impersonate_bodytype_legacy || ..()
	return ..()

/datum/species/protean/get_worn_legacy_bodytype(mob/living/carbon/human/H)
	return H?.impersonate_bodytype_legacy || ..()

/datum/species/protean/create_organs(mob/living/carbon/human/H)
	H.synth_color = TRUE
	. = ..()

	// todo: this is utter shitcode and will break if we CHECK_TICK in SSticker, and should probably be part of postspawn or something
	spawn(5) //Let their real nif load if they have one
		if(!H.nif)
			var/obj/item/nif/bioadap/new_nif = new()
			new_nif.quick_implant(H)
		else
			H.nif.durability = rand(21,25)

	var/obj/item/hardsuit/protean/prig = new /obj/item/hardsuit/protean(H)
	prig.myprotean = H

/datum/species/protean/equip_survival_gear(var/mob/living/carbon/human/H)
	var/obj/item/storage/box/box = new /obj/item/storage/box/survival/synth(H)
	var/obj/item/stack/material/steel/metal_stack = new(box)
	metal_stack.amount = 3 // Less starting steel due to regen changes
	new /obj/item/fbp_backup_cell(box)
	var/obj/item/clothing/accessory/permit/nanotech/permit = new(box)
	permit.set_name(H.real_name)

	if(H.backbag == 1) //Somewhat misleading, 1 == no bag (not boolean)
		H.equip_to_slot_or_del(box, /datum/inventory_slot_meta/abstract/hand/left)
	else
		H.equip_to_slot_or_del(box, /datum/inventory_slot_meta/abstract/put_in_backpack)

/datum/species/protean/handle_death(var/mob/living/carbon/human/H, gibbed)		// citadel edit - FUCK YOU ACTUALLY GIB THE MOB AFTER REMOVING IT FROM THE BLOB HOW HARD CAN THIS BE!!
	var/deathmsg = "<span class='userdanger'>You have died as a Protean. You may be revived by nanite chambers (once available), but otherwise, you may roleplay as your disembodied posibrain or respawn on another character.</span>"
	// force eject inv
	H.drop_inventory(TRUE, TRUE, TRUE)
	// force eject v*re
	H.release_vore_contents(TRUE, TRUE)
	if(istype(H.temporary_form, /mob/living/simple_mob/protean_blob))
		var/mob/living/simple_mob/protean_blob/B = H.temporary_form
		to_chat(B, deathmsg)
	else if(!gibbed)
		to_chat(H, deathmsg)
	ASYNC
		if(!QDELETED(H))
			H.gib()

/datum/species/protean/proc/getActualDamage(mob/living/carbon/human/H)
	var/obj/item/organ/external/E = H.get_organ(BP_TORSO)
	return E.brute_dam + E.burn_dam

/datum/species/protean/handle_environment_special(mob/living/carbon/human/H, datum/gas_mixture/environment, dt)
	if((getActualDamage(H) > damage_to_blob) && isturf(H.loc)) //So, only if we're not a blob (we're in nullspace) or in someone (or a locker, really, but whatever).
		H.nano_intoblob()
		return ..() //Any instakill shot runtimes since there are no organs after this. No point to not skip these checks, going to nullspace anyway.

	var/obj/item/organ/internal/nano/refactory/refactory = locate() in H.internal_organs
	if(refactory && !(refactory.status & ORGAN_DEAD) && refactory.processingbuffs)

		//Steel adds regen
		if(protean_requires_healing(H) && refactory.get_stored_material(MAT_STEEL) >= METAL_PER_TICK)  //  Regen without blobform, though relatively slow compared to blob regen
			H.add_modifier(/datum/modifier/protean/steel, origin = refactory)

	return ..()
*/
/datum/species/protean/proc/statpanel_status(client/C, mob/living/carbon/human/H)
	stat_panel_data[PANEL_DISPLAY_PANEL] = panel

	var/obj/item/organ/internal/nano/refactory/refactory = H.nano_get_refactory()
	if(refactory && !(refactory.status & ORGAN_FAILING))
		stat_panel_data("- -- --- Refactory Metal Storage --- -- -")
		var/max = refactory.max_storage
		for(var/material in refactory.stored_materials)
			var/amount = refactory.get_stored_material(material)
			stat_panel_data("[capitalize(material)]", "[amount]/[max]")
	else
		stat_panel_data("- -- --- REFACTORY ERROR! --- -- -")

	stat_panel_data("- -- --- Abilities (Shift+LMB Examines) --- -- -")



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
		/datum/quirk/equipping/force_equip_item(src, /datum/inventory_slot_meta/inventory/back, suit)
		to_chat(src, span_warning("You deploy your nanosuit."))
		return

	to_chat(src, span_warning("You don't have a nanocluster RIG. Somehow."))

/datum/species/protean/get_species_description()
	return "Sometimes very advanced civilizations will produce the ability to swap into manufactured, robotic bodies. And sometimes \
			<i>very</i> advanced civilizations have the option of 'nanoswarm' bodies. Effectively a single robot body comprised \
			of millions of tiny nanites working in concert to maintain cohesion."

#undef DAM_SCALE_FACTOR
#undef METAL_PER_TICK
