const std = @import("std");
const Cell = @import("../Cell.zig").Cell;
const NewTickBlock = @import("../OtherTypes.zig").NewTickBlock;

const getNumTick = @import("../Logic.zig").getNumTick;
const check = @import("../Cell.zig").Check.clockwiseCheck3x3;
const allocator = std.heap.wasm_allocator;

pub const Separator = struct {
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
        const dx = matrix.*[x][y].status >> 16;
        const dy = matrix.*[x][y].status & 0xFFFF;
        if (matrix.*[x][y].status != 0) {
            switch (cell.id) {
                1 => {
                    if ((cell.status % 10) == 0 and ((dx != ux or dy != uy))) {
                        newMatrix.*[ux][uy].status = (matrix.*[ux][uy].status / 10) * 10 + 1;
                        buffResult.*.append(allocator, .{
                            .x = ux,
                            .y = uy,
                            .newStatus = (matrix.*[ux][uy].status / 10) * 10 + 1,
                        }) catch {};
                    }
                },
                3 => {
                    const dtime = (matrix.*[ux][uy].status & 0xFFFF) / 10;
                    const dx2 = @as(isize, @intCast(ux)) - @as(isize, @intCast(x));
                    const dy2 = @as(isize, @intCast(uy)) - @as(isize, @intCast(y));
                    const dir: usize = switch (dx2) {
                        0 => switch (dy2) {
                            -1 => 2,
                            1 => 0,
                            else => unreachable,
                        },
                        -1 => if (dy == 0) 3 else unreachable,
                        1 => if (dy == 0) 1 else unreachable,
                        else => unreachable,
                    };

                    newMatrix.*[ux][uy].status = (((getNumTick() + dtime) * 10 + 1) << 16) | ((dtime * 10) + dir);
                    buffResult.*.append(allocator, .{
                        .x = ux,
                        .y = uy,
                        .newStatus = (newMatrix.*[ux][uy].status & 0xFFFF),
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
