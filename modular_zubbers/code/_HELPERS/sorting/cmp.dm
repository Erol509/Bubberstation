/proc/cmp_fusion_reaction_asc(singleton/fusion_reaction/A, singleton/fusion_reaction/B)
	return A.priority - B.priority

/proc/cmp_fusion_reaction_des(singleton/fusion_reaction/A, singleton/fusion_reaction/B)
	return B.priority - A.priority
