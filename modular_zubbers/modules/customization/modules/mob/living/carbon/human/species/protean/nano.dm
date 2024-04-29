#define CHECK_MOBILITY(target, flags) (target.mobility_flags & flags)

// // // // External Organs
/obj/item/organ/external/chest/unbreakable/nano

/obj/item/organ/external/head/unbreakable/nano

/obj/item/organ/external/arm/unbreakable/nano

/obj/item/organ/external/arm/right/unbreakable/nano

/obj/item/organ/external/leg/unbreakable/nano

/obj/item/organ/external/leg/right/unbreakable/nano


// // // Internal Organs
/obj/item/organ/internal/nano

/obj/item/organ/internal/nano/orchestrator
	name = "orchestrator module"
	desc = "A small computer, designed for highly parallel workloads."
	icon = 'modular_zubbers/modules/customization/modules/mob/living/carbon/human/species/protean/sprites/protean.dmi'
	icon_state = "orchestrator"


/obj/item/organ/internal/nano/refactory
	name = "refactory module"
	desc = "A miniature metal processing unit and nanite factory."
	icon = 'modular_zubbers/modules/customization/modules/mob/living/carbon/human/species/protean/sprites/protean.dmi'
	icon_state = "refactory"


	var/list/stored_materials = list(MAT_STEEL = 0)
	var/max_storage = 10000
	var/processingbuffs = FALSE

/obj/item/organ/internal/nano/refactory/proc/get_stored_material(var/material)
	if(ORGAN_FAILING)
		return 0
	return stored_materials[material] || 0

/obj/item/organ/internal/nano/refactory/proc/add_stored_material(var/material,var/amt)
	if(ORGAN_FAILING)
		return 0
	var/increase = min(amt,max(max_storage-stored_materials[material],0))
	if(isnum(stored_materials[material]))
		stored_materials[material] += increase
	else
		stored_materials[material] = increase

	return increase

/obj/item/organ/internal/nano/refactory/proc/use_stored_material(var/material,var/amt)
	if(ORGAN_FAILING)
		return 0

	var/available = stored_materials[material]

	//Success
	if(available >= amt)
		var/new_amt = available-amt
		if(new_amt == 0)
			stored_materials -= material
		else
			stored_materials[material] = new_amt
		return amt

	//Failure
	return 0

/obj/item/mmi/posibrain/nano
	name = "protean posibrain"
	desc = "A more advanced version of the standard posibrain, typically found in protean bodies."
	icon = 'modular_zubbers/modules/customization/modules/mob/living/carbon/human/species/protean/sprites/protean.dmi'
	icon_state = "posi"


/obj/item/mmi/posibrain/nano
	name = "protean posibrain"
	desc = "A more advanced version of the standard posibrain, typically found in protean bodies."
	icon = 'modular_zubbers/modules/customization/modules/mob/living/carbon/human/species/protean/sprites/protean.dmi'
	icon_state = "posi"

/obj/item/mmi/posibrain/nano/Initialize(mapload)
	. = ..()
	icon_state = "posi"

/obj/item/hardsuit/protean
	name = "nanosuit control cluster"
	icon_state = "nanomachine_rig"
	armor_type = /datum/armor/hardsuit/protean
	slowdown = 2
	var/mob/living/carbon/human/myprotean
	//helm_type = /obj/item/clothing/head/helmet/space/hardsuit/protean
	//boot_type = /obj/item/clothing/shoes/magboots/hardsuit/protean
	//chest_type = /obj/item/clothing/suit/space/hardsuit/protean
	//glove_type = /obj/item/clothing/gloves/gauntlets/hardsuit/protean

/datum/armor/hardsuit/protean
	melee = 0
	bullet = 0
	laser = 0
	energy = 0
	bomb = 0
	bio = 10

/obj/item/hardsuit/protean/relaymove(mob/user, var/direction)
	if(!CHECK_MOBILITY(user, MOBILITY_CAN_MOVE))
		return
	forced_move(direction, user, FALSE, TRUE)

/obj/item/hardsuit/protean/check_suit_access(mob/living/carbon/human/user)
	if(user == myprotean)
		return TRUE

/obj/item/clothing/head/helmet/space/hardsuit/protean
	name = "mass"
	desc = "A helmet-shaped clump of nanomachines."

/obj/item/clothing/gloves/gauntlets/hardsuit/protean
	name = "mass"
	desc = "Glove-shaped clusters of nanomachines."

/obj/item/clothing/shoes/magboots/hardsuit/protean
	name = "mass"
	desc = "Boot-shaped clusters of nanomachines."

/obj/item/clothing/suit/space/hardsuit/protean
	name = "mass"
	desc = "A body-hugging mass of nanomachines."
	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank,/obj/item/suit_cooling_unit,/obj/item/melee/baton,/obj/item/bluespace_radio)
