// CHEST AND HEAD

/obj/item/bodypart/chest/protean
	bodytype = BODYTYPE_ROBOTIC
	name = "Protean Chest"
	limb_id = SPECIES_PROTEAN

/obj/item/bodypart/head/protean
	bodytype = BODYTYPE_ROBOTIC
	name = "Protean Head"
	limb_id = SPECIES_PROTEAN

// ARMS

/obj/item/bodypart/arm/protean
	bodytype = BODYTYPE_ROBOTIC
	name = "Protean Left Arm"
	limb_id = SPECIES_PROTEAN

/obj/item/bodypart/arm/right/protean
	bodytype = BODYTYPE_ROBOTIC
	name = "Protean Right Arm"
	limb_id = SPECIES_PROTEAN

// LEGS
//
/obj/item/bodypart/leg/protean
	bodytype = BODYTYPE_ROBOTIC
	name = "Protean Left Leg"
	limb_id = SPECIES_PROTEAN

/obj/item/bodypart/leg/right/protean
	bodytype = BODYTYPE_ROBOTIC
	name = "Protean Right Leg"
	limb_id = SPECIES_PROTEAN

// Internal Organs

/obj/item/organ/internal/heart/protean
	name = "Protean Heart"
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/internal/orchestrator/protean
	name = "orchestrator module"
	desc = "A small computer, designed for highly parallel workloads."
	icon = 'modular_zubbers/modules/customization/modules/mob/living/carbon/human/species/protean/sprites/protean.dmi'
	icon_state = "orchestrator"
	organ_flags = ORGAN_ROBOTIC


/obj/item/organ/internal/refactory/protean
	name = "refactory module"
	desc = "A miniature metal processing unit and nanite factory."
	icon = 'modular_zubbers/modules/customization/modules/mob/living/carbon/human/species/protean/sprites/protean.dmi'
	icon_state = "refactory"
	organ_flags = ORGAN_ROBOTIC

/obj/item/mmi/posibrain/brain/protean
	name = "protean posibrain"
	desc = "A more advanced version of the standard posibrain, typically found in protean bodies."
	icon = 'modular_zubbers/modules/customization/modules/mob/living/carbon/human/species/protean/sprites/protean.dmi'
	icon_state = "posi"

/obj/item/mmi/posibrain/nano/Initialize(mapload)
	. = ..()
	icon_state = "posi"
