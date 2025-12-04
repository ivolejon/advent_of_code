const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;

pub var sum: usize = 0;

pub fn solution() !void {
    var general_purpose_allocator: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = general_purpose_allocator.deinit();
    const gpa = general_purpose_allocator.allocator();

    const file_path = "src/data/2025_2_solution1_solution2_gift_shop.txt";

    const text = try util.readFile(gpa, file_path);
    defer gpa.free(text);

    // var data = try util.split_string(gpa, text, ",");
    // defer data.deinit(gpa);
    //
    var it = std.mem.tokenizeScalar(u8, text, ',');
    while (it.next()) |row| {
        var it2 = std.mem.tokenizeScalar(u8, row, '-');
        const start = it2.next() orelse continue;
        const end = it2.next() orelse continue;
        var range = try createRange(gpa, start, end);
        defer range.deinit(gpa);
        var invalid_ids = try checkInvalidIds(gpa, range.items);
        defer invalid_ids.deinit(gpa);

        for (invalid_ids.items) |id| {
            print("{d}\n", .{id});
            sum = sum + id;
        }
    }
    print("Sum: {d}\n", .{sum});
}

fn checkInvalidIds(allocator: std.mem.Allocator, range: []usize) !std.ArrayList(usize) {
    var invalidIds: std.ArrayList(usize) = .empty;
    for (range, 0..) |text, index| {
        const str = try std.fmt.allocPrint(
            allocator,
            "{d}",
            .{text},
        );
        defer allocator.free(str);
        const isValid = try isRepeatingPattern(str);
        if (isValid) {
            try invalidIds.append(allocator, range[index]);
        }
    }
    return invalidIds;
}

fn createRange(allocator: std.mem.Allocator, str_start: []const u8, str_end: []const u8) !std.ArrayList(usize) {
    var range: std.ArrayList(usize) = .empty;
    const start: usize = std.fmt.parseInt(usize, str_start, 10) catch 0;
    const end: usize = std.fmt.parseInt(usize, str_end, 10) catch 0;
    for (start..end + 1) |i| {
        try range.append(allocator, i);
    }
    return range;
}

pub fn isRepeatingPattern(s: []const u8) !bool {
    const n = s.len;
    if (n == 0) {
        return false;
    }
    if (n == 1) {
        return false;
    }

    var buffer: [2048]u8 = undefined; // Antar att max stränglängd < 1024

    _ = @memcpy(buffer[0..n], s);
    _ = @memcpy(buffer[n .. 2 * n], s);
    const ss = buffer[0 .. 2 * n];

    // (exempel: "abab" -> "abababab", interior är "bababa")
    const interior = ss[1 .. 2 * n - 1];
    const index = std.mem.indexOfPos(u8, interior, 0, s);
    return index != null;
}

test "create_range fn test 1" {
    const a = std.testing.allocator;
    const res = try createRange(a, "11", "22");
    const expected: [12]usize = [_]usize{ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22 };
    try std.testing.expectEqualSlices(usize, res, &expected);
}

test "check_invalid_ids fn test 1" {
    const a = std.testing.allocator;
    var range: std.ArrayList(usize) = .empty;
    defer range.deinit(a);
    for (11..22 + 1) |i| {
        try range.append(a, i);
    }
    var res = try checkInvalidIds(a, range.items);
    defer res.deinit(a);
    const expected: [2]usize = [_]usize{ 11, 22 };
    try std.testing.expectEqualSlices(usize, res.items, &expected);
}
