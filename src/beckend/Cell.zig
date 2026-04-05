const std = @import("std");
const other = @import("OtherTypes.zig");
const NewTickBlock = other.NewTickBlock;
const DirectionsEnergyBlock = other.DirectionsEnergyBlock;

pub const Cell = struct {
    id: u8,
    status: u32,

    pub fn new() Cell {
        return Cell{ .id = 0, .status = 0 };
    }
};

pub const Check = struct {
    pub fn clockwiseCheck3x3(
        x: usize,
        y: usize,
        matrix: *[][1000]Cell,
        newMatrix: *[][1000]Cell,
        buffResult: *std.ArrayList(NewTickBlock),
        logic: fn (
            matrix: *[][1000]Cell,
            newMatrix: *[][1000]Cell,
            x: usize,
            y: usize,
            ux: usize,
            uy: usize,
            buffResult: *std.ArrayList(NewTickBlock),
            cell: Cell,
        ) void,
    ) void {
        var dx: isize = 0;
        var dy: isize = -1;

        const ix: isize = @intCast(x);
        const iy: isize = @intCast(y);

        for (0..4) |_| {
            const nx: isize = ix + dx;
            const ny: isize = iy + dy;

            if (nx >= 0 and nx < 1000 and ny >= 0 and ny < 1000) {
                const ux: usize = @intCast(nx);
                const uy: usize = @intCast(ny);
                const cell = matrix.*[ux][uy];

                logic(matrix, newMatrix, x, y, ux, uy, buffResult, cell);
            }

            const new_dx = dy;
            const new_dy = -dx;
            dx = new_dx;
            dy = new_dy;
        }
    }

    pub fn clockwiseCheck3x3EnergyBlock(
        x: usize,
        y: usize,
        matrix: *[][1000]Cell,
        newMatrix: *[][1000]Cell,
        buffResult: *std.ArrayList(NewTickBlock),
        logic: fn (
            matrix: *[][1000]Cell,
            newMatrix: *[][1000]Cell,
            x: usize,
            y: usize,
            ux: usize,
            uy: usize,
            buffResult: *std.ArrayList(NewTickBlock),
            cell: Cell,
        ) void,
    ) void {
        const dx: isize = DirectionsEnergyBlock[(matrix.*[x][y].status / 10) - 1][0];
        const dy: isize = DirectionsEnergyBlock[(matrix.*[x][y].status / 10) - 1][1];

        const ix: isize = @intCast(x);
        const iy: isize = @intCast(y);

        const nx: isize = ix + dx;
        const ny: isize = iy + dy;

        if (nx >= 0 and nx < 1000 and ny >= 0 and ny < 1000) {
            const ux: usize = @intCast(nx);
            const uy: usize = @intCast(ny);
            const cell = matrix.*[ux][uy];

            logic(matrix, newMatrix, x, y, ux, uy, buffResult, cell);
        }
    }
};
