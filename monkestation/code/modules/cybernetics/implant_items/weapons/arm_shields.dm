/*!
 * Contains the blueshield arm implants
 */

// Arm shields, they allow you to block and shove/disarm attackers.
/obj/item/arm_shield
	name = "S.A.Y.A. arm defense system"
	desc = "Durable retractable blade made from hard materials, featuring a wide shield design. \
			Purposefully sacrificing offensive capabilities and user mobility in favor of enhanced protection. \
			Primarily issued to personnel safeguarding valuable targets. \
			One of the many combat augmentations created by Muramasa Munitions."
	icon = 'monkestation/code/modules/cybernetics/icons/items_and_weapons.dmi'
	lefthand_file = 'monkestation/code/modules/cybernetics/icons/swords_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/cybernetics/icons/swords_righthand.dmi'
	icon_state = "arm_shield"
	inhand_icon_state = "arm_shield"
	force = 50
	damtype = STAMINA
	armour_penetration = 100
	block_chance = 50
	attack_verb_continuous = list("bashes", "bonks", "whacks", "smacks", "domes", "thumps", "knocks")
	attack_verb_simple = list("bash", "bonk", "whack", "smack", "dome", "thump", "knock")
	/// If both arms are deployed, we enter shield stance
	var/shield_stance = FALSE

/obj/item/arm_shield/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_MURAMASA)

/obj/item/arm_shield/equipped(mob/living/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_HANDS || !istype(user))
		return

	var/obj/item/arm_shield/right_shield = user.get_held_items_for_side(RIGHT_HANDS)
	var/obj/item/arm_shield/left_shield = user.get_held_items_for_side(LEFT_HANDS)
	if(!istype(right_shield) || !istype(left_shield))
		shield_stance = FALSE
		block_chance = initial(block_chance)
	else // We've equipped both shields, means we enter shield stance
		right_shield.shield_stance = TRUE
		left_shield.shield_stance = TRUE
		right_shield.block_chance += 20
		left_shield.block_chance += 20
		user.apply_status_effect(/datum/status_effect/shield_stance)

	var/side = user.get_held_index_of_item(src)
	if(side == LEFT_HANDS)
		transform = null
	else
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/arm_shield/dropped(mob/living/user)
	. = ..()
	shield_stance = FALSE
	block_chance = initial(block_chance)

	if(!user.has_status_effect(/datum/status_effect/shield_stance))
		return
	user.remove_status_effect(/datum/status_effect/shield_stance)

/obj/item/arm_shield/attack(mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!shield_stance)
		return
	// TODO Add double-hit

/obj/item/arm_shield/attack_secondary(mob/living/victim, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	user.disarm(victim)
	victim.Knockdown(0.1 SECONDS)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/arm_shield/attack_self(mob/living/user)
	if(!shield_stance)
		return

	var/obj/item/arm_shield/left_shield = user.get_held_items_for_side(LEFT_HANDS, FALSE)
	var/obj/item/arm_shield/right_shield = user.get_held_items_for_side(RIGHT_HANDS, FALSE)
	if(!istype(left_shield, right_shield)) //Checks for if your hands are the same type (which they would be if you were dual wielding the shields.)
		to_chat(user, span_warning("Need both shields deployed to parry."))
		return

	if(!do_after(user, 0.5 SECONDS, user, IGNORE_USER_LOC_CHANGE, extra_checks = !CALLBACK(left_shield, PROC_REF(dropped)) || !CALLBACK(right_shield, PROC_REF(dropped))))
		to_chat(user, span_warning("You were interrupted!"))
		return
	/* XANTODO: Parry :)
	user.apply_status_effect(/datum/status_effect/shield_mantis_defense)
	to_chat(user, span_notice("You enter defensive stance with your mantis blades."))
	return
	user.remove_status_effect(/datum/status_effect/shield_mantis_defense)
	to_chat(user, span_notice("You stop blocking with your blades."))
	*/

/datum/status_effect/shield_stance
	id = "mantis_defensive"
	alert_type =  /atom/movable/screen/alert/status_effect/shield_mantis_defense
	tick_interval = -1

/datum/status_effect/shield_stance/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/arm_shield_slowdown)
	owner.balloon_alert_to_viewers("starts blocking!")

/datum/status_effect/shield_stance/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/arm_shield_slowdown)
	owner.balloon_alert_to_viewers("stops blocking!")

//blocking with blades slow you down
/datum/movespeed_modifier/arm_shield_slowdown
	multiplicative_slowdown = 0.25

/atom/movable/screen/alert/status_effect/shield_mantis_defense
	name = "Defensive stance"
	desc = "You are blocking attacks and projectiles with your shields. During this you will be slowed down."
	icon_state = "shield_arm"
