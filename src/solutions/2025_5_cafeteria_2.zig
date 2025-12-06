const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;
const ArrayList = std.ArrayList;

const Range = struct {
    start: u64,
    end: u64,
};

pub fn solution() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var values: ArrayList(u64) = .empty;
    var ranges: ArrayList([2]u64) = .empty;
    var merged_ranges: ArrayList([2]u64) = .empty;
    var sum: u64 = 0;
    defer values.deinit(allocator);
    defer ranges.deinit(allocator);
    defer merged_ranges.deinit(allocator);

    const data = try util.readFile(std.heap.page_allocator, "src/data/2025_5_cafeteria.txt");
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
            const val = try std.fmt.parseInt(u64, row, 10);
            try values.append(allocator, val);
            continue;
        }
        const range = try parseAndCreateRange(row);
        try ranges.append(allocator, range);
    }

    const typeof = @TypeOf(ranges.items[0]);
    std.mem.sort(typeof, ranges.items, {}, lessThanFn);

    // We assign the first range to start merging
    try merged_ranges.append(allocator, [2]u64{ ranges.items[0][0], ranges.items[0][1] });

    for (ranges.items) |range| {
        var last_merged = merged_ranges.items[merged_ranges.items.len - 1];
        if (range[0] <= last_merged[1]) { // Extending current range
            last_merged[1] = @max(last_merged[1], range[1]);
            merged_ranges.items[merged_ranges.items.len - 1] = last_merged;
        } else { // We have a new range
            try merged_ranges.append(allocator, [2]u64{ range[0], range[1] });
        }
    }

    for (merged_ranges.items) |range| {
        sum += range[1] - range[0] + 1;
    }

    print("Is fresh count: {d}\n", .{sum});
}

fn lessThanFn(_: void, a: [2]u64, b: [2]u64) bool {
    return a[0] < b[0];
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
