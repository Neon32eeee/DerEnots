const std = @import("std");
const logic = @import("Logic.zig");
const other = @import("OtherTypes.zig");

export fn getNewTickBlockSize() usize {
    return @sizeOf(other.NewTickBlock);
}

comptime {
    _ = &logic;
}
