pub const NewTickBlock = extern struct {
    x: u32,
    y: u32,
    newStatus: u32,
};

pub const DirectionsEnergyBlock = [4][2]isize{
    .{ 0, -1 },
    .{ -1, 0 },
    .{ 0, 1 },
    .{ 1, 0 },
};
