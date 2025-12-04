const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;

const Position = struct {
    x: i32,
    y: i32,
};

const Grid = struct {
    grid: std.AutoHashMap(Position, u32),

    pub fn new() Grid {
        return Grid{ .grid = std.AutoHashMap(Position, u32).init(std.heap.page_allocator) };
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
};

pub fn solution() !void {
    var grid = Grid.new();
    var current_pos: Position = .{ .x = 0, .y = 0 };
    try grid.deliver(current_pos); // Leverans på start pos.
    const data = try util.readFile(std.heap.page_allocator, "src/data/2015_3_perfectly_spherical_house_in_a_vacuum_1.txt");
    for (data) |byte| {
        switch (byte) {
            '>' => current_pos.x += 1,
            '<' => current_pos.x -= 1,
            '^' => current_pos.y += 1,
            'v' => current_pos.y -= 1,
            else => {},
        }
        try grid.deliver(current_pos);
    }
    const unique_houses = grid.countHouses();
    print("Number of unique houses that received at least one present: {d}\n", .{unique_houses});
}
