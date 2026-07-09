const std = @import("std");
const Cell = @import("Cell.zig").Cell;

const Void = @import("Blocks/Void.zig").Void;
const EnargyBlock = @import("Blocks/EnergyBloc.zig").EnergyBlock;
const Button = @import("Blocks/Button.zig").Button;
const Dalye = @import("Blocks/Dalye.zig").Dalye;
const Separator = @import("Blocks/Separator.zig").Separator;

const NewTickBlock = @import("OtherTypes.zig").NewTickBlock;
const DefaultBlock = @import("Blocks/DefaultBlock.zig").DefaultBlock;

const allocator = std.heap.wasm_allocator;

var saved_ptr: ?[*]NewTickBlock = null;
var saved_len: usize = 0;
var numTick: usize = 0;

pub const GameLogic = struct {
    matrix: [][1000]Cell,
    tickResult: std.ArrayList(NewTickBlock),
    notvoidBlocks: std.ArrayList([2]usize),
    registeredBlocks: std.ArrayList(DefaultBlock),

    pub inline fn init() ?*GameLogic {
        const matrix = allocator.alloc([1000]Cell, 1000) catch {
            return null;
        };
        const tickResult = std.ArrayList(NewTickBlock).empty;
        const notvoidBlocks = std.ArrayList([2]usize).empty;

        var registeredBlocks = std.ArrayList(DefaultBlock).empty;

        var BLocks = [_]DefaultBlock{
            Void,
            EnargyBlock,
            Button,
            Dalye,
            Separator,
        };

        registeredBlocks.appendSlice(allocator, @constCast(&BLocks)) catch {
            return null;
        };

        for (0..1000) |x| {
            for (0..1000) |y| {
                matrix[x][y] = Cell.new();
            }
        }

        const ptr = allocator.create(GameLogic) catch {
            return null;
        };
        ptr.* = .{
            .matrix = matrix,
            .tickResult = tickResult,
            .notvoidBlocks = notvoidBlocks,
            .registeredBlocks = registeredBlocks,
        };
        return ptr;
    }

    pub fn update(
        self: *GameLogic,
        x: usize,
        y: usize,
        newId: u8,
        newStatus: u32,
    ) usize {
        if (x >= 1000 or y >= 1000) return 1;

        self.matrix[x][y].id = newId;

        if (newId > self.registeredBlocks.items.len) return 1;
        return self.registeredBlocks.items[newId].update(self, x, y, newStatus);
    }

    pub fn tick(self: *GameLogic) ?[*]NewTickBlock {
        var newMatrix = allocator.dupe([1000]Cell, self.matrix) catch return null;

        self.tickResult.clearRetainingCapacity();

        for (self.notvoidBlocks.items) |i| {
            const x = i[0];
            const y = i[1];

            const cell = self.matrix[x][y];

            if (@as(usize, @intCast(cell.id)) > self.registeredBlocks.items.len) return null;
            self.registeredBlocks.items[@intCast(cell.id)].tick(x, y, &self.matrix, &newMatrix, &self.tickResult);
        }

        numTick += 1;

        allocator.free(self.matrix);
        self.matrix = newMatrix;

        saved_ptr = self.tickResult.items.ptr;
        saved_len = self.tickResult.items.len;

        return self.tickResult.items.ptr;
    }

    pub inline fn deinit(self: *GameLogic) void {
        allocator.free(self.matrix);
        allocator.destroy(self);
    }
};

pub export fn GameInit() ?*GameLogic {
    return GameLogic.init();
}

pub export fn GameDeinit(self: *GameLogic) void {
    self.deinit();
}

pub export fn GameUpdate(
    self: *GameLogic,
    x: usize,
    y: usize,
    newId: u8,
    newStatus: u32,
) usize {
    return self.update(x, y, newId, newStatus);
}

pub export fn GameTick(self: *GameLogic) [*]NewTickBlock {
    return (self.tick() orelse unreachable);
}

pub export fn getArrayLen() usize {
    return saved_len;
}

pub export fn getNumTick() usize {
    return numTick;
}

export fn freeArray() void {
    if (saved_ptr) |p| {
        allocator.free(p[0..saved_len]);
        saved_ptr = null;
        saved_len = 0;
    }
}

export fn GameStop(self: *GameLogic) void {
    numTick = 0;
    self.deinit();
}

export fn getTimeDalye(self: *GameLogic, x: usize, y: usize) u32 {
    if ((self.matrix[x][y].status >> 16) % 10 == 0) return (self.matrix[x][y].status & 0xFFFF) / 10;
    return ((self.matrix[x][y].status >> 16) / 10) - numTick;
}

test "GameLogic init" {
    var gl = GameLogic.init() orelse {
        std.debug.print("Error", .{});
        return;
    };
    defer gl.deinit();
}

test "GameLogic update" {
    var gl = GameLogic.init() orelse {
        std.debug.print("Error", .{});
        return;
    };
    defer gl.deinit();

    const res = gl.update(67, 0, 1, 0);

    try std.testing.expectEqual(@as(usize, 0), res);
}

test "GameTick" {
    var gl = GameLogic.init() orelse {
        std.debug.print("Error", .{});
        return;
    };
    defer gl.deinit();

    _ = gl.update(67, 1, 2, 1);
    _ = gl.update(67, 0, 1, 0);
    _ = gl.update(66, 1, 1, 0);
    _ = gl.update(67, 2, 1, 0);
    _ = gl.update(68, 1, 1, 0);

    const res = gl.tick() orelse return error.Invalid;

    for (res[0..saved_len]) |r| {
        std.debug.print("\n{d}", .{r.newStatus});
    }
}
