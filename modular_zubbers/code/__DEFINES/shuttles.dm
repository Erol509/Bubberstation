

// Jump status defines
#define BS_JUMP_IDLE 0
#define BS_JUMP_CALLED 1
#define BS_JUMP_INITIATED 2
#define BS_JUMP_COMPLETED 3

// max reserve shuttle dock size defines

/// Neither of a shuttle's dimensions should exceed this size if it is to dock at encounters or outposts.
#define RESERVE_DOCK_MAX_SIZE_LONG 56
/// Only one of a shuttle's dimensions may exceed this size if it is to dock at encounters or outposts.
#define RESERVE_DOCK_MAX_SIZE_SHORT 40
/// Default # of tiles of padding around an autogenerated reserve shuttle dock.
#define RESERVE_DOCK_DEFAULT_PADDING 3
