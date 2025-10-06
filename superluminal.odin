package superluminal

foreign import superluminal "lib/PerformanceAPI_MT.lib";

SuppressTailCallOptimization :: struct {
	SuppressTrailCall: [3]i64,
}

DEFAULT_COLOR :: 0xFFFFFFFF

MAKE_COLOR :: #force_inline proc(r, g, b: u8) -> u32 {
	return transmute(u32)[4]u8{0xFF, b, g, r}
}

@(deferred_none=EndEvent)
InstrumentationScope :: proc(inID: string, inData: string = "", inColor: u32 = DEFAULT_COLOR) {
	BeginEvent(inID, inData, inColor)
}

SetCurrentThreadName :: #force_inline proc(inThreadName: string) {
    SetCurrentThreadName_N(raw_data(inThreadName), u16(len(inThreadName)))
}

BeginEvent :: #force_inline proc(inThreadName: string, inData: string, inColor: u32) {
    BeginEvent_N(raw_data(inThreadName), u16(len(inThreadName)), raw_data(inData), u16(len(inData)), inColor)
}

@(default_calling_convention="c", link_prefix="PerformanceAPI_")
foreign superluminal {
	/**
	 * Set the name of the current thread to the specified thread name. 
	 *
	 * @param inThreadName The thread name as an UTF8 encoded string.
	 * @param inThreadNameLength The length of the thread name, in characters, excluding the null terminator.
	 */
	SetCurrentThreadName_N :: proc(inThreadName: [^]u8, inThreadNameLength: u16) ---

	/**
	 * Begin an instrumentation event with the specified ID and runtime data, both with an explicit length.
	 
	 * It works the same as the regular BeginEvent function (see docs above). The difference is that it allows you to specify the length of both the ID and the data,
	 * which is useful for languages that do not have null-terminated strings.
	 *
	 * Note: both lengths should be specified in the number of characters, not bytes, excluding the null terminator.
	 */
	BeginEvent_N :: proc(inID: [^]u8, inIDLength: u16, inData: [^]u8, inDataLength: u16, inColor: u32) ---

	/**
	 * End an instrumentation event. Must be matched with a call to BeginEvent within the same function
	 * Note: the return value can be ignored. It is only there to prevent calls to the function from being optimized to jmp instructions as part of tail call optimization.
	 */
	EndEvent :: proc() -> SuppressTailCallOptimization ---

	/**
	 * Call this function when a fiber starts running
	 *
	 * @param inFiberID    The currently running fiber
	 */
	RegisterFiber :: proc(inFiberId: u64) ---

	/**
	 * Call this function before a fiber ends
	 *
	 * @param inFiberID    The currently running fiber
	 */
	UnregisterFiber :: proc(inFiberId: u64) ---

	/**
	 * The call to the Windows SwitchFiber function should be surrounded by BeginFiberSwitch and EndFiberSwitch calls. For example:
	 * 
	 *		BeginFiberSwitch(currentFiber, otherFiber)
	 *		SwitchToFiber(otherFiber)
	 *		EndFiberSwitch(currentFiber)
	 *
	 * @param inCurrentFiberID    The currently running fiber
	 * @param inNewFiberID		  The fiber we're switching to
	 */
	BeginFiberSwitch :: proc(inCurrentFiberId: u64, inNewFiberId: u64) ---

	/**
	 * The call to the Windows SwitchFiber function should be surrounded by BeginFiberSwitch and EndFiberSwitch calls
	 * 	
	 *		BeginFiberSwitch(currentFiber, otherFiber)
	 *		SwitchToFiber(otherFiber)
	 *		EndFiberSwitch(currentFiber)
	 *
	 * @param inFiberID    The fiber that was running before the call to SwitchFiber (so, the same as inCurrentFiberID in the BeginFiberSwitch call)
	 */
    EndFiberSwitch :: proc(inFiberID: u64) ---
}
