const std = @import("std");
const Cell = @import("../Cell.zig").Cell;
const NewTickBlock = @import("../OtherTypes.zig").NewTickBlock;
const DirectionsEnergyBlock = @import("../OtherTypes.zig").DirectionsEnergyBlock;

const getNumTick = @import("../Logic.zig").getNumTick;
const check = @import("../Cell.zig").Check.clockwiseCheck3x3;
const allocator = std.heap.wasm_allocator;

pub const Dalye = struct {
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
        if (((matrix.*[x][y].status >> 16) / 10) == getNumTick() and ((matrix.*[x][y].status >> 16) % 10) == 1) {
            const dx = @as(isize, @intCast(ux)) - @as(isize, @intCast(x));
            const dy = @as(isize, @intCast(uy)) - @as(isize, @intCast(y));
            const d = [2]isize{ dx, dy };

            const d2 = DirectionsEnergyBlock[(matrix.*[x][y].status & 0xFFF) % 10];

            if (!std.mem.eql(isize, d[0..], d2[0..])) {
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
            }

            if (dx == 1) {
                const dtime = (matrix.*[x][y].status & 0xFFFF) / 10;
                newMatrix.*[x][y].status = ((dtime * 10) << 16) | ((dtime * 10) & 0xFFF);
                buffResult.*.append(allocator, .{
                    .x = x,
                    .y = y,
                    .newStatus = dtime,
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
