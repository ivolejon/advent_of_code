const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const splitSequence = std.mem.splitSequence;
const trim = std.mem.trim;
const Allocator = std.mem.Allocator;

const Coordinate = struct {
    x: i64,
    y: i64,
};

pub fn solution() !void {
    const allocator = std.heap.page_allocator;
    const data = try util.readFile(allocator, "src/data/2025_9_movie_theater.txt");

    var coords: ArrayList(Coordinate) = .empty;

    defer {
        coords.deinit(allocator);
        allocator.free(data);
    }

    var it = std.mem.tokenizeScalar(u8, data, '\n');
    while (it.next()) |row| {
        var cord_it = std.mem.tokenizeScalar(u8, row, ',');
        const x = cord_it.next() orelse return error.InvalidFormat;
        const y = cord_it.next() orelse return error.InvalidFormat;
        const cord_x = try std.fmt.parseInt(i64, x, 10);
        const cord_y = try std.fmt.parseInt(i64, y, 10);
        const line_cords = Coordinate{
            .x = cord_x,
            .y = cord_y,
        };
        try coords.append(allocator, line_cords);
    }

    var max_area: u64 = 0;

    for (0..coords.items.len, 0..) |_, i| {
        const c1 = coords.items[i];
        for (0..coords.items.len, 0..) |_, j| {
            const c2 = coords.items[j];
            const l = @abs(c1.x - c2.x) + 1;
            const w = @abs(c1.y - c2.y) + 1;
            const area = l * w;
            if (area > max_area) {
                print("New max area found: {d} with coords ({d},{d}) and ({d},{d})\n", .{ area, c1.x, c1.y, c2.x, c2.y });
                max_area = area;
            }
        }
    }

    print("Cords: {}\n", .{coords});

    print("Hej, max area is {d}\n", .{max_area});
}
