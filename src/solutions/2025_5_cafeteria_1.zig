const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;
const ArrayList = std.ArrayList;

pub fn solution() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var values: ArrayList(u64) = .empty;
    var ranges: ArrayList([2]u64) = .empty;
    defer values.deinit(allocator);
    defer ranges.deinit(allocator);
    var is_fresh: std.AutoHashMap(u64, u64) = .init(allocator);
    defer is_fresh.deinit();

    const data = try util.readFile(std.heap.page_allocator, "src/data/2025_5_cafeteria_1.txt");
    var it = std.mem.tokenizeScalar(u8, data, '\n');
    var proc_val = false;

    while (it.next()) |row| {
        const i = std.mem.indexOfAny(u8, row, "-");
        if (i == null) {
            proc_val = true;
        }
        //true = We parse the values
        //false = We parse the ranges
        if (proc_val) {
            const val = std.fmt.parseInt(u64, row, 10) catch unreachable;
            try values.append(allocator, val);
            continue;
        }
        const range = try parseAndCreateRange(row);
        try ranges.append(allocator, range);
    }

    for (values.items) |v| {
        for (ranges.items) |numbers| {
            if (v >= numbers[0] and v <= numbers[1]) {
                _ = try is_fresh.getOrPut(v);
            }
        }
    }

    print("Is fresh count: {d}\n", .{is_fresh.count()});
}

fn parseAndCreateRange(str_range: []const u8) ![2]u64 {
    var it = std.mem.tokenizeScalar(u8, str_range, '-');

    const start_str = it.next() orelse return error.InvalidRangeFormat;
    const end_str = it.next() orelse return error.InvalidRangeFormat;

    const start = try std.fmt.parseInt(u64, start_str, 10);
    const end = try std.fmt.parseInt(u64, end_str, 10);
    const low_high = [2]u64{ start, end };
    return low_high;
}

test "Parse and create range" {
    const range_str = "100-200";
    const range = try parseAndCreateRange(range_str);
    try std.testing.expectEqual(range[0], 100);
    try std.testing.expectEqual(range[1], 200);
}
