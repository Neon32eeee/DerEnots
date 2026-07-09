const std = @import("std");
const Cell = @import("../Cell.zig").Cell;
const NewTickBlock = @import("../OtherTypes.zig").NewTickBlock;

const check = @import("../Cell.zig").Check.clockwiseCheck3x3;
const allocator = std.heap.wasm_allocator;

const GameLogic = @import("../Logic.zig").GameLogic;

pub const DefaultBlock = struct {
    tickLogic: *const fn (
        matrix: *[][1000]Cell,
        newMatrix: *[][1000]Cell,
        x: usize,
        y: usize,
        ux: usize,
        uy: usize,
        buffResult: *std.ArrayList(NewTickBlock),
        cell: Cell,
    ) void,
    check: *const fn (
        x: usize,
        y: usize,
        matrix: *[][1000]Cell,
        newMatrix: *[][1000]Cell,
        buffResult: *std.ArrayList(NewTickBlock),
        logic: *const fn (
            matrix: *[][1000]Cell,
            newMatrix: *[][1000]Cell,
            x: usize,
            y: usize,
            ux: usize,
            uy: usize,
            buffResult: *std.ArrayList(NewTickBlock),
            cell: Cell,
        ) void,
    ) void,
    updateFn: ?*const fn (
        game: *GameLogic,
        x: usize,
        y: usize,
        newStatus: u32,
    ) usize = null,

    pub fn tick(
        self: DefaultBlock,
        x: usize,
        y: usize,
        matrix: *[][1000]Cell,
        newMatrix: *[][1000]Cell,
        buffResult: *std.ArrayList(NewTickBlock),
    ) void {
        self.check(x, y, matrix, newMatrix, buffResult, self.tickLogic);
    }

    pub fn update(
        self: DefaultBlock,
        game: *GameLogic,
        x: usize,
        y: usize,
        newStatus: u32,
    ) usize {
        if (self.updateFn == null) {
            const newBlock = [2]usize{ x, y };
            game.matrix[x][y].status = newStatus;
            game.notvoidBlocks.append(allocator, newBlock) catch return 1;
            return 0;
        } else {
            return self.updateFn.?(game, x, y, newStatus);
        }
    }
};
