const std = @import("std");
const Cell = @import("../Cell.zig").Cell;
const NewTickBlock = @import("../OtherTypes.zig").NewTickBlock;

const getNumTick = @import("../Logic.zig").getNumTick;
const check = @import("../Cell.zig").Check.checkVoid;
const allocator = std.heap.wasm_allocator;

const DefaultBlock = @import("DefaultBlock.zig").DefaultBlock;
const GameLogic = @import("../Logic.zig").GameLogic;

pub const Lamp = DefaultBlock{
    .tickLogic = tickLogic,
    .check = check,
    .updateFn = update,
};

fn tickLogic(
    matrix: *[][1000]Cell,
    newMatrix: *[][1000]Cell,
    x: usize,
    y: usize,
    ux: usize,
    uy: usize,
    buffResult: *std.ArrayList(NewTickBlock),
    cell: Cell,
) void {
    _ = matrix;
    _ = newMatrix;
    _ = x;
    _ = y;
    _ = ux;
    _ = uy;
    _ = buffResult;
    _ = cell;
}

fn update(
    game: *GameLogic,
    x: usize,
    y: usize,
    newStatus: u32,
) usize {
    for (game.notvoidBlocks.items, 0..) |i, id| {
        if (i[0] == x and i[1] == y) {
            _ = game.notvoidBlocks.swapRemove(id);
        }
    }
    game.matrix[x][y].status = newStatus;
    return 0;
}
