#define CHECK_MOBILITY(target, flags) (target.mobility_flags & flags)

// // // // External Organs
/obj/item/bodypart/chest/nano
	bodytype = BODYTYPE_ROBOTIC
	name = "Protean Chest"
	limb_id = SPECIES_PROTEAN

/obj/item/bodypart/head/nano
	bodytype = BODYTYPE_ROBOTIC
	name = "Protean Head"
	limb_id = SPECIES_PROTEAN

/obj/item/bodypart/arm/nano
	bodytype = BODYTYPE_ROBOTIC
	name = "Protean Left Arm"
	limb_id = SPECIES_PROTEAN

/obj/item/bodypart/arm/right/nano
	bodytype = BODYTYPE_ROBOTIC
	name = "Protean Right Arm"
	limb_id = SPECIES_PROTEAN

/obj/item/bodypart/leg/nano
	bodytype = BODYTYPE_ROBOTIC
	name = "Protean Left Leg"
	limb_id = SPECIES_PROTEAN

/obj/item/bodypart/leg/right/nano
	bodytype = BODYTYPE_ROBOTIC
	name = "Protean Right Leg"
	limb_id = SPECIES_PROTEAN

// // // Internal Organs
/obj/item/organ/internal/nano
	name = "Protean Heart"

/obj/item/organ/internal/nano/orchestrator
	name = "orchestrator module"
	desc = "A small computer, designed for highly parallel workloads."
	icon = 'modular_zubbers/modules/customization/modules/mob/living/carbon/human/species/protean/sprites/protean.dmi'
	icon_state = "orchestrator"
	organ_flags = ORGAN_ROBOTIC


/obj/item/organ/internal/nano/refactory
	name = "refactory module"
	desc = "A miniature metal processing unit and nanite factory."
	icon = 'modular_zubbers/modules/customization/modules/mob/living/carbon/human/species/protean/sprites/protean.dmi'
	icon_state = "refactory"
	organ_flags = ORGAN_ROBOTIC


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
	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank)
