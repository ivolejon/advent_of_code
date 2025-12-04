const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;

const Position = struct {
    x: i32,
    y: i32,
};

const Grid = struct {
    grid: std.AutoHashMap(Position, u32),

    pub fn new(a: std.mem.Allocator) Grid {
        return Grid{ .grid = std.AutoHashMap(Position, u32).init(a) };
    }
    pub fn deliver(self: *Grid, pos: Position) !void {
        const count = self.grid.get(pos) orelse 0;
        try self.grid.put(pos, count + 1);
    }
    pub fn iterator(self: *Grid) @TypeOf(self.grid.iterator()) {
        return self.grid.iterator();
    }

    pub fn countHouses(self: *Grid) usize {
        return self.grid.count();
    }
    pub fn deinit(self: *Grid) void {
        self.grid.deinit();
    }
};

pub fn solution() !void {
    var general_purpose_allocator: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = general_purpose_allocator.deinit();
    const gpa = general_purpose_allocator.allocator();

    var grid = Grid.new(gpa);
    defer grid.deinit();
    var santas_current_pos: Position = .{ .x = 0, .y = 0 };
    var robo_santas_current_pos: Position = .{ .x = 0, .y = 0 };

    var santas_turn = true;

    try grid.deliver(santas_current_pos); // Leverans på start pos.
    try grid.deliver(robo_santas_current_pos); // Leverans på start pos.

    const data = try util.readFile(std.heap.page_allocator, "src/data/2015_3_perfectly_spherical_house_in_a_vacuum_1.txt");
    for (data) |dir| {
        if (santas_turn) {
            const new_pos = getNewPos(santas_current_pos, dir);
            try grid.deliver(new_pos);
            santas_current_pos = new_pos;
            santas_turn = false;
        } else {
            const new_pos = getNewPos(robo_santas_current_pos, dir);
            try grid.deliver(new_pos);
            robo_santas_current_pos = new_pos;
            santas_turn = true;
        }
    }
    const unique_houses_count = grid.countHouses();
    print("Antal unika hus som fått minst en present: {d}\n", .{unique_houses_count});
}

fn getNewPos(position: Position, update: u8) Position {
    var newPos = position;
    switch (update) {
        '>' => newPos.x += 1,
        '<' => newPos.x -= 1,
        '^' => newPos.y += 1,
        'v' => newPos.y -= 1,
        else => {},
    }
    return newPos;
}
