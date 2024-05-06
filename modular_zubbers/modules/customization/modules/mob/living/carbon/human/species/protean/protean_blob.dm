// Simple animal nanogoopeyness
/mob/living/simple_mob/protean_blob
	name = "protean blob"
	desc = "Some sort of big viscous pool of jelly."
	//icon = 'icons/mob/clothing/species/protean/protean.dmi'
	icon_state = "to_puddle"

	faction = "neutral"
	maxHealth = 250
	health = 250

	var/mob/living/carbon/human/humanform
	var/obj/item/organ/internal/nano/refactory/refactory
	var/datum/modifier/healing

	var/datum/weakref/prev_left_hand
	var/datum/weakref/prev_right_hand


/mob/living/simple_mob/protean_blob/proc/rig_transform()
	set name = "Modify Form - Hardsuit"
	set desc = "Allows a protean blob to solidify its form into one extremely similar to a hardsuit."
	set category = "Abilities"

	if(istype(loc, /obj/item/hardsuit/protean))
		var/obj/item/hardsuit/protean/prig = loc
		src.forceMove(get_turf(prig))
		prig.forceMove(humanform)
		return

	if(isturf(loc))
		var/obj/item/hardsuit/protean/prig
		for(var/obj/item/hardsuit/protean/O in humanform.contents)
			prig = O
			break
		if(prig)
			prig.forceMove(get_turf(src))
			src.forceMove(prig)
			return

