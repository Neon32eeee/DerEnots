const std = @import("std");
const Cell = @import("../Cell.zig").Cell;
const NewTickBlock = @import("../OtherTypes.zig").NewTickBlock;

const getNumTick = @import("../Logic.zig").getNumTick;
const check = @import("../Cell.zig").Check.clockwiseCheck3x3EnergyBlock;
const allocator = std.heap.wasm_allocator;

pub const EnergyBlock = struct {
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
        if ((matrix.*[x][y].status % 10) == 1) {
            switch (cell.id) {
                1 => {
                    newMatrix.*[ux][uy].status = (matrix.*[ux][uy].status / 10) * 10 + 1;
                    buffResult.*.append(allocator, .{
                        .x = ux,
                        .y = uy,
                        .newStatus = (matrix.*[ux][uy].status / 10) * 10 + 1,
                    }) catch {};

                    newMatrix.*[x][y].status = (matrix.*[x][y].status / 10) * 10;
                    buffResult.*.append(allocator, .{
                        .x = x,
                        .y = y,
                        .newStatus = (matrix.*[x][y].status / 10) * 10,
                    }) catch {};
                },
                3 => {
                    const dtime = (matrix.*[ux][uy].status & 0xFFFF) / 10;
                    const dx = @as(isize, @intCast(ux)) - @as(isize, @intCast(x));
                    const dy = @as(isize, @intCast(uy)) - @as(isize, @intCast(y));
                    const dir: usize = switch (dx) {
                        0 => switch (dy) {
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

                    newMatrix.*[x][y].status = (matrix.*[x][y].status / 10) * 10;
                    buffResult.*.append(allocator, .{
                        .x = x,
                        .y = y,
                        .newStatus = (matrix.*[x][y].status / 10) * 10,
                    }) catch {};
                },
                4 => {
                    newMatrix.*[ux][uy].status = (x << 16) | (y & 0xFFFF);
                    buffResult.*.append(allocator, .{
                        .x = ux,
                        .y = uy,
                        .newStatus = (x << 16) | (y & 0xFFFF),
                    }) catch {};

                    newMatrix.*[x][y].status = (matrix.*[x][y].status / 10) * 10;
                    buffResult.*.append(allocator, .{
                        .x = x,
                        .y = y,
                        .newStatus = (matrix.*[x][y].status / 10) * 10,
                    }) catch {};
                },
                5 => {
                    newMatrix.*[ux][uy].status = 1;
                    buffResult.*.append(allocator, .{
                        .x = ux,
                        .y = uy,
                        .newStatus = 1,
                    }) catch {};

                    newMatrix.*[x][y].status = (matrix.*[x][y].status / 10) * 10;
                    buffResult.*.append(allocator, .{
                        .x = x,
                        .y = y,
                        .newStatus = (matrix.*[x][y].status / 10) * 10,
                    }) catch {};
                },
                else => {},
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
