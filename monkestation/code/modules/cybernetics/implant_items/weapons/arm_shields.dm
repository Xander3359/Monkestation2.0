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
	hitsound = 'sound/items/pillow_hit2.ogg'
	/// If both arms are deployed, we enter shield stance
	var/shield_stance = FALSE
	/// Cooldown before we can parry again
	COOLDOWN_DECLARE(parry_cooldown)
	/// Boolean, used to update the worn icon
	var/parrying = FALSE
	/// Color of the shield outline when parrying
	var/static/parry_color = "#dd1122"

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
	var/obj/item/arm_shield/other_shield = user.get_inactive_held_item()
	if(istype(other_shield))
		other_shield.shield_stance = FALSE
		other_shield.block_chance = initial(block_chance)

	if(user.has_status_effect(/datum/status_effect/shield_stance))
		user.remove_status_effect(/datum/status_effect/shield_stance)
	if(user.has_status_effect(/datum/status_effect/parry_stance))
		user.remove_status_effect(/datum/status_effect/parry_stance)

/obj/item/arm_shield/build_worn_icon(default_layer, default_icon_file, isinhands, female_uniform, override_state, override_file)
	var/mutable_appearance/standing = ..()
	if(parrying)
		standing.add_filter("outline", 1, list("type" = "outline", "color" = parry_color, "size" = 1))
		return standing
	standing.remove_filter("outline", 1, list("type" = "outline", "color" = parry_color, "size" = 1))
	return standing

/obj/item/arm_shield/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!shield_stance)
		return
	var/obj/item/arm_shield/off_hand = user.get_inactive_held_item()
	if(QDELETED(off_hand) || !istype(off_hand))
		return
	if(off_hand == src)
		return // Don't add another strike if we're attacking with our offhand (preventing infinite attacks)
	addtimer(CALLBACK(src, PROC_REF(double_strike), target, user, user.get_inactive_held_item()), 0.2 SECONDS)

/// Performs a second attack, after a delay
/obj/item/arm_shield/proc/double_strike(mob/living/target_mob, mob/living/user, obj/item/arm_shield/weapon)
	if(QDELETED(target_mob) || QDELETED(user) || QDELETED(weapon))
		return
	if(weapon != user.get_inactive_held_item())
		return
	if(!user.Adjacent(target_mob))
		return
	weapon.melee_attack_chain(user, target_mob, null)

/obj/item/arm_shield/attack_secondary(mob/living/victim, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	user.disarm(victim)
	victim.Knockdown(0.1 SECONDS)
	playsound(src, 'sound/items/pillow_hit.ogg', get_clamped_volume(), TRUE, extrarange = -1, falloff_distance = 0)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/arm_shield/attack_self(mob/living/user)
	if(!shield_stance || parrying)
		return
	if(!COOLDOWN_FINISHED(src, parry_cooldown))
		balloon_alert(user, "on cooldown")
		return

	var/obj/item/arm_shield/left_shield = user.get_held_items_for_side(LEFT_HANDS, FALSE)
	var/obj/item/arm_shield/right_shield = user.get_held_items_for_side(RIGHT_HANDS, FALSE)
	if(!istype(left_shield, right_shield)) //Checks for if your hands are the same type (which they would be if you were dual wielding the shields.)
		to_chat(user, span_warning("Need both shields deployed to parry."))
		return

	if(!do_after(user, 0.5 SECONDS, user, IGNORE_USER_LOC_CHANGE, extra_checks = !CALLBACK(left_shield, PROC_REF(dropped)) || !CALLBACK(right_shield, PROC_REF(dropped)), hidden = TRUE))
		COOLDOWN_START(src, parry_cooldown, 5 SECONDS)
		return
	user.apply_status_effect(/datum/status_effect/parry_stance)
	to_chat(user, span_notice("You attempt to parry."))

/obj/item/arm_shield/IsReflect(def_zone)
	if(parrying)
		return TRUE
	return FALSE

//---- Applies a status effect that gives you slowdown. Active when you have both shields deployed
/datum/status_effect/shield_stance
	id = "shield_stance"
	alert_type =  /atom/movable/screen/alert/status_effect/shield_arm_stance
	tick_interval = -1

/datum/status_effect/shield_stance/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/arm_shield_slowdown)
	owner.balloon_alert_to_viewers("starts blocking!")

/datum/status_effect/shield_stance/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/arm_shield_slowdown)
	owner.balloon_alert_to_viewers("stops blocking!")

/datum/movespeed_modifier/arm_shield_slowdown
	multiplicative_slowdown = 1

/atom/movable/screen/alert/status_effect/shield_arm_stance
	name = "Defensive stance"
	desc = "You are blocking attacks and projectiles with your shields. During this you will be slowed down."
	icon_state = "shield_arm"

//---- Short parry window when you have both arms active and use in hand
/datum/status_effect/parry_stance
	id = "parry_stance"
	alert_type = /atom/movable/screen/alert/status_effect/shield_arm_parry
	duration = 1 SECONDS
	var/obj/item/arm_shield/left_shield
	var/obj/item/arm_shield/right_shield

/datum/status_effect/parry_stance/on_apply()
	. = ..()
	left_shield = owner.get_held_items_for_side(LEFT_HANDS, FALSE)
	right_shield = owner.get_held_items_for_side(RIGHT_HANDS, FALSE)
	if(!istype(left_shield) || !istype(right_shield))
		return FALSE // Can't parry if we lose a shield

	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	RegisterSignal(left_shield, COMSIG_ITEM_HIT_REACT, PROC_REF(on_hit_react))
	RegisterSignal(right_shield, COMSIG_ITEM_HIT_REACT, PROC_REF(on_hit_react))
	left_shield.add_filter("outline", 1, list("type" = "outline", "color" = left_shield.parry_color, "size" = 1))
	left_shield.parrying = TRUE
	right_shield.add_filter("outline", 1, list("type" = "outline", "color" = right_shield.parry_color, "size" = 1))
	right_shield.parrying = TRUE
	owner.update_held_items()

/datum/status_effect/parry_stance/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	UnregisterSignal(left_shield, list(COMSIG_ITEM_HIT_REACT))
	UnregisterSignal(right_shield, list(COMSIG_ITEM_HIT_REACT))
	left_shield.remove_filter("outline")
	left_shield.parrying = FALSE
	right_shield.remove_filter("outline")
	right_shield.parrying = FALSE
	owner.update_held_items()

/datum/status_effect/parry_stance/proc/on_hit_react(obj/item/arm_shield, mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	SIGNAL_HANDLER
	if(isnull(hitby))
		return
	// Reflectable projectiles bounce back towards the shooter, this is handled by a snowflake has_status_effect(/datum/status_effect/parry_stance)
	if(isprojectile(hitby))
		return
	// Checks that we've been attacked by a person
	var/mob/living/attacker = get(hitby, /mob/living)
	if(!istype(attacker))
		return

	//XANTODO: Custom parry effect/sound
	var/owner_turf = get_turf(owner)
	new arm_shield.block_effect(owner_turf, COLOR_YELLOW)
	playsound(src, arm_shield.block_sound, BLOCK_SOUND_VOLUME, vary = TRUE)
	//XANTODO: Custom parry effect/sound

	attacker.Paralyze(1 SECONDS)
	owner.disarm(attacker)
	attacker.Knockdown(3 SECONDS)
	qdel(src)

	return COMPONENT_HIT_REACTION_BLOCK

/atom/movable/screen/alert/status_effect/shield_arm_parry
	name = "Parry stance"
	desc = "You are preparing to parry an attack..."
	icon_state = "shield_arm_parry"
