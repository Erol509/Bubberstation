/// Value or the next integer in a positive direction: Ceil(-1.5) = -1 , Ceil(1.5) = 2
#define Ceil(value) ( -round(-(value)) )

/proc/Ceiling(x, y=1)
	return -round(-x / y) * y

// Performs a linear interpolation between a and b.
// Note: weight=0 returns a, weight=1 returns b, and weight=0.5 returns the mean of a and b.
/proc/Interpolate(a, b, weight = 0.5)
	return a + (b - a) * weight // Equivalent to: a*(1 - weight) + b*weight
