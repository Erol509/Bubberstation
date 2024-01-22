//! Defines for subsystems and overlays
//!
//! Lots of important stuff in here, make sure you have your brain switched on
//! when editing this file

///Call qdel with a force of TRUE after initialization
#define INITIALIZE_HINT_QDEL_FORCE 3


// Subsystem init_order, from highest priority to lowest priority
// Subsystems shutdown in the reverse of the order they initialize in
// The numbers just define the ordering, they are meaningless otherwise.

#define INIT_ORDER_TEXT 103	//Should remain highest as other subsystems may throw runtimes if this did not init before them.

#define INIT_ORDER_SPEECH_CONTROLLER 92

#define INIT_ORDER_NETWORKS 45

#define INIT_ORDER_OVERMAP -25

#define INIT_ORDER_DEMO -99 // o avoid a bunch of changes related to initialization being written, do this last

// Subsystem fire priority, from lowest to highest priority
// If the subsystem isn't listed here it's either DEFAULT or PROCESS (if it's a processing subsystem child)


#define FIRE_PRIOTITY_SMOOTHING 35
#define FIRE_PRIORITY_NETWORKS 40

#define FIRE_PRIOTITY_BURNING 40

#define FIRE_PRIORITY_ATMOS_ADJACENCY 300

#define FIRE_PRIORITY_CALLBACKS 600

#define FIRE_PRIORITY_OVERMAP_MOVEMENT 850


// Air subsystem subtasks
#define SSAIR_TURF_CONDUCTION 6
#define SSAIR_REBUILD_PIPENETS 7
#define SSAIR_EQUALIZE 8
#define SSAIR_TURF_POST_PROCESS 10
#define SSAIR_FINALIZE_TURFS 11
#define SSAIR_ATMOSMACHINERY_AIR 12
#define SSAIR_DEFERRED_AIRS 13



//! ## Overlays subsystem

///Compile all the overlays for an atom from the cache lists
// |= on overlays is not actually guaranteed to not add same appearances but we're optimistically using it anyway.
#define COMPILE_OVERLAYS(A) \
	do{ \
		var/list/ad = A.add_overlays; \
		var/list/rm = A.remove_overlays; \
		if(LAZYLEN(rm)){ \
			A.overlays -= rm; \
			rm.Cut(); \
		} \
		if(LAZYLEN(ad)){ \
			A.overlays |= ad; \
			ad.Cut(); \
		} \
		for(var/I in A.alternate_appearances){ \
			var/datum/atom_hud/alternate_appearance/AA = A.alternate_appearances[I]; \
			if(AA.transfer_overlays){ \
				AA.copy_overlays(A, TRUE); \
			} \
		} \
		A.flags_1 &= ~OVERLAY_QUEUED_1; \
	}while(FALSE)
