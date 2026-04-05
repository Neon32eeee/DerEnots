const std = @import("std");
const Cell = @import("../Cell.zig").Cell;
const NewTickBlock = @import("../OtherTypes.zig").NewTickBlock;

const check = @import("../Cell.zig").Check.clockwiseCheck3x3;
const allocator = std.heap.wasm_allocator;

pub const Button = struct {
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
        if (matrix.*[x][y].status == 1) {
            switch (cell.id) {
                1 => {
                    newMatrix.*[ux][uy].status = (matrix.*[ux][uy].status / 10) * 10 + 1;
                    buffResult.*.append(allocator, .{
                        .x = ux,
                        .y = uy,
                        .newStatus = (matrix.*[ux][uy].status / 10) * 10 + 1,
                    }) catch {};
                },
                4 => {
                    newMatrix.*[ux][uy].status = (x << 16) | (y & 0xFFFF);
                    buffResult.*.append(allocator, .{
                        .x = ux,
                        .y = uy,
                        .newStatus = (x << 16) | (y & 0xFFFF),
                    }) catch {};
                },
                else => {},
            }
            if ((ux > x and ux - x == 1) or (x > ux and x - ux == 1)) {
                newMatrix.*[x][y].status = 0;
                buffResult.*.append(allocator, .{
                    .x = x,
                    .y = y,
                    .newStatus = 0,
                }) catch {};
            }
        }
    }

    pub fn tick(
        x: usize,
        y: usize,
        matrix: *[][1000]Cell,
        newMatrix: *[][1000]Cell,
        buffResult: *std.ArrayList(NewTickBlock),
    ) void {
        check(x, y, matrix, newMatrix, buffResult, tickLogic);
    }
};
