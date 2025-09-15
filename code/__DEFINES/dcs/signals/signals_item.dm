// /obj/item signals

/// from /datum/component/cleave_attack/perform_sweep(): (atom/target, obj/item/item, mob/living/user, params)
#define COMSIG_ATOM_CLEAVE_ATTACK "atom_cleave_attack"
	/// allows cleave attack to hit things it normally wouldn't
	#define ATOM_ALLOW_CLEAVE_ATTACK (1<<0)

// /obj/item/implant signals
///from base of /obj/item/implant/proc/activate(): ()
#define COMSIG_IMPLANT_ACTIVATED "implant_activated"
///from base of /obj/item/implant/proc/implant(): (list/args)
#define COMSIG_IMPLANT_IMPLANTING "implant_implanting"
	#define COMPONENT_STOP_IMPLANTING (1<<0)
///called on already installed implants when a new one is being added in /obj/item/implant/proc/implant(): (list/args, obj/item/implant/new_implant)
#define COMSIG_IMPLANT_OTHER "implant_other"
	//#define COMPONENT_STOP_IMPLANTING (1<<0) //The name makes sense for both
	#define COMPONENT_DELETE_NEW_IMPLANT (1<<1)
	#define COMPONENT_DELETE_OLD_IMPLANT (1<<2)

/// called on implants, after a successful implantation: (mob/living/target, mob/user, silent, force)
#define COMSIG_IMPLANT_IMPLANTED "implant_implanted"

/// called on implants, after an implant has been removed: (mob/living/source, silent, special)
#define COMSIG_IMPLANT_REMOVED "implant_removed"

/// called as a mindshield is implanted: (mob/user)
#define COMSIG_PRE_MINDSHIELD_IMPLANT "pre_mindshield_implant"
	/// Did they successfully get mindshielded?
	#define COMPONENT_MINDSHIELD_PASSED (NONE)
	/// Did they resist the mindshield?
	#define COMPONENT_MINDSHIELD_RESISTED (1<<0)

/// called once a mindshield is implanted: (mob/user)
#define COMSIG_MINDSHIELD_IMPLANTED "mindshield_implanted"
	/// Are we the reason for deconversion?
	#define COMPONENT_MINDSHIELD_DECONVERTED (1<<0)

///called on implants being implanted into someone with an uplink implant: (datum/component/uplink)
#define COMSIG_IMPLANT_EXISTING_UPLINK "implant_uplink_exists"
	//This uses all return values of COMSIG_IMPLANT_OTHER

// /obj/item/pda signals

///called on pda when the user changes the ringtone: (mob/living/user, new_ringtone)
#define COMSIG_TABLET_CHANGE_ID "comsig_tablet_change_id"
	#define COMPONENT_STOP_RINGTONE_CHANGE (1<<0)
#define COMSIG_TABLET_CHECK_DETONATE "pda_check_detonate"
	#define COMPONENT_TABLET_NO_DETONATE (1<<0)

// /obj/item/radio signals

///called from base of /obj/item/radio/proc/set_frequency(): (list/args)
#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"
///called from base of /obj/item/radio/proc/talk_into(): (atom/movable/M, message, channel)
#define COMSIG_RADIO_NEW_MESSAGE "radio_new_message"
///called from base of /obj/item/radio/proc/on_receive_messgae(): (list/data)
#define COMSIG_RADIO_RECEIVE_MESSAGE "radio_receive_message"

// /obj/item/pen signals

///called after rotation in /obj/item/pen/attack_self(): (rotation, mob/living/carbon/user)
#define COMSIG_PEN_ROTATED "pen_rotated"

// /obj/item/gun signals

///called in /obj/item/gun/fire_gun (user, target, flag, params)
#define COMSIG_GUN_TRY_FIRE "gun_try_fire"
	#define COMPONENT_CANCEL_GUN_FIRE (1<<0)
///called in /obj/item/gun/process_fire (src, target, params, zone_override)
#define COMSIG_MOB_FIRED_GUN "mob_fired_gun"
///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GUN_FIRED "gun_fired"
///called in /obj/item/gun/process_chamber (src)
#define COMSIG_GUN_CHAMBER_PROCESSED "gun_chamber_processed"
///called in /obj/item/gun/ballistic/process_chamber (casing)
#define COMSIG_CASING_EJECTED "casing_ejected"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_FIRE_CASING "fire_casing"
///from the base of /obj/item/ammo_casing/ready_proj() : (atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
#define COMSIG_CASING_READY_PROJECTILE "casing_ready_projectile"
///sent to the projectile after an item is spawned by the projectile_drop element: (new_item)
#define COMSIG_PROJECTILE_ON_SPAWN_DROP "projectile_on_spawn_drop"

// Jetpack things
// Please kill me

//called in /obj/item/tank/jetpack/proc/turn_on() : ()
#define COMSIG_JETPACK_ACTIVATED "jetpack_activated"
	#define JETPACK_ACTIVATION_FAILED (1<<0)
//called in /obj/item/tank/jetpack/proc/turn_off() : ()
#define COMSIG_JETPACK_DEACTIVATED "jetpack_deactivated"

//called in /obj/item/organ/internal/cyberimp/chest/thrusters/proc/toggle() : ()
#define COMSIG_THRUSTER_ACTIVATED "jetmodule_activated"
	#define THRUSTER_ACTIVATION_FAILED (1<<0)
//called in /obj/item/organ/internal/cyberimp/chest/thrusters/proc/toggle() : ()
#define COMSIG_THRUSTER_DEACTIVATED "jetmodule_deactivated"

// /obj/item/camera signals

///from /obj/item/camera/captureimage(): (atom/target, mob/user)
#define COMSIG_CAMERA_IMAGE_CAPTURED "camera_image_captured"

// /obj/item/grenade signals

///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_DETONATE "grenade_prime"
//called from many places in grenade code (armed_by, nade, det_time, delayoverride)
#define COMSIG_MOB_GRENADE_ARMED "grenade_mob_armed"
///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_ARMED "grenade_armed"

///from [/obj/item/proc/tryEmbed] sent when trying to force an embed (mainly for projectiles and eating glass)
#define COMSIG_EMBED_TRY_FORCE "item_try_embed"
	#define COMPONENT_EMBED_SUCCESS (1<<1)
// FROM [/obj/item/proc/updateEmbedding] sent when an item's embedding properties are changed : ()
#define COMSIG_ITEM_EMBEDDING_UPDATE "item_embedding_update"

#define COMSIG_ITEM_ATTACK "item_attack"
///from base of obj/item/attack_self(): (/mob)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"
//from base of obj/item/attack_self_secondary(): (/mob)
#define COMSIG_ITEM_ATTACK_SELF_SECONDARY "item_attack_self_secondary"
///from base of obj/item/attack_atom(): (/atom, /mob, list/modifiers)
#define COMSIG_ITEM_ATTACK_ATOM "item_attack_atom"
///from base of obj/item/pre_attack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_PRE_ATTACK "item_pre_attack"
/// From base of [/obj/item/proc/pre_attack_secondary()]: (atom/target, mob/user, params)
#define COMSIG_ITEM_PRE_ATTACK_SECONDARY "item_pre_attack_secondary"
	#define COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN (1<<0)
	#define COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN (1<<1)
	#define COMPONENT_SECONDARY_CALL_NORMAL_ATTACK_CHAIN (1<<2)
/// From base of [/obj/item/proc/attack_secondary()]: (atom/target, mob/user, params)
#define COMSIG_ITEM_ATTACK_SECONDARY "item_attack_secondary"
///from base of [obj/item/attack()]: (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"
///from base of obj/item/embedded(): (atom/target, obj/item/bodypart/part)
#define COMSIG_ITEM_EMBEDDED "item_embedded"
///from base of datum/component/embedded/safeRemove(): (mob/living/carbon/victim)
#define COMSIG_ITEM_UNEMBEDDED "item_unembedded"
/// from base of obj/item/failedEmbed()
#define COMSIG_ITEM_FAILED_EMBED "item_failed_embed"

/// from base of datum/element/disarm_attack/secondary_attack(), used to prevent shoving: (victim, user, send_message)
#define COMSIG_ITEM_CAN_DISARM_ATTACK "item_pre_disarm_attack"
	#define COMPONENT_BLOCK_ITEM_DISARM_ATTACK (1<<0)

///from /obj/item/assembly/proc/pulsed(mob/pulser)
#define COMSIG_ASSEMBLY_PULSED "assembly_pulsed"

///from base of /obj/item/mmi/set_brainmob(): (mob/living/brain/new_brainmob)
#define COMSIG_MMI_SET_BRAINMOB "mmi_set_brainmob"

/// from base of /obj/item/slimepotion/speed/interact_with_atom(): (obj/target, /obj/src, mob/user)
#define COMSIG_SPEED_POTION_APPLIED "speed_potion"
	#define SPEED_POTION_STOP (1<<0)

/// from /obj/item/detective_scanner/scan(): (mob/user, list/extra_data)
#define COMSIG_DETECTIVE_SCANNED "det_scanned"

/// Sent from /obj/item/update_weight_class(). (old_w_class, new_w_class)
#define COMSIG_ITEM_WEIGHT_CLASS_CHANGED "item_weight_class_changed"
/// Sent from /obj/item/update_weight_class(), to its loc. (obj/item/changed_item, old_w_class, new_w_class)
#define COMSIG_ATOM_CONTENTS_WEIGHT_CLASS_CHANGED "atom_contents_weight_class_changed"

///Sent from /obj/item/skillchip/on_implant()
#define COMSIG_SKILLCHIP_IMPLANTED "skillchip_implanted"

///Sent from /obj/item/skillchip/on_remove()
#define COMSIG_SKILLCHIP_REMOVED "skillchip_removed"

/// from /obj/item/use: (used, ...)
#define COMSIG_ITEM_USED "item_used"
	#define BLOCK_ITEM_USE (1<<0)
