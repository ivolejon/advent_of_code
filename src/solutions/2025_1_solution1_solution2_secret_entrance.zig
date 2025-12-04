const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;

const Direction = enum { LEFT, RIGHT, UNKNOWN };

var times_dail_hit_zero: u32 = 0; // Globala variabel för att räkna hur många gånger visaren träffar 0
var times_passes_zero: i32 = 0;

pub fn solution() !void {
    var general_purpose_allocator: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = general_purpose_allocator.deinit();
    const gpa = general_purpose_allocator.allocator();

    const file_path = "src/data/2025_1_solution1_solution2_secret_entrance.txt";

    const data = try util.readFile(gpa, file_path);
    defer gpa.free(data);

    var it = std.mem.tokenizeScalar(u8, data, '\n');

    var dail_sum: i32 = 50; // Startpostition på visaren är 50

    while (it.next()) |row| {
        dail_sum = try updateDail(dail_sum, row);
    }

    print("Slutposition på visaren: {d}\n", .{times_dail_hit_zero});
    print("Antal varv runt visaren: {d}\n", .{times_passes_zero});
}

fn updateDail(sum: i32, row: []const u8) !i32 {
    const direction = try getDirection(row);
    const rotate_value = try parseInt(row);
    const new_value, const passes = switch (direction) {
        Direction.LEFT => dailLeft(sum, rotate_value),
        Direction.RIGHT => dailRight(sum, rotate_value),
        Direction.UNKNOWN => .{ sum, 0 },
    };
    times_passes_zero = times_passes_zero + passes;
    if (new_value == 0) {
        times_dail_hit_zero = times_dail_hit_zero + 1;
    }

    return new_value;
}

fn dailLeft(sum: i32, value: i32) struct { i32, i32 } {
    var passes: i32 = @divFloor(value, 100);
    const remainder: i32 = @mod(value, 100);

    if (sum > 0 and sum - remainder <= 0) {
        passes = passes + 1;
    }

    return .{ @mod((sum - value), 100), passes };
}

fn dailRight(sum: i32, value: i32) struct { i32, i32 } {
    var passes: i32 = @divFloor(value, 100);
    const remainder: i32 = @mod(value, 100);

    if (sum + remainder >= 100) {
        passes = passes + 1;
    }

    return .{ @mod((sum + value), 100), passes };
}

fn parseInt(row: []const u8) !i32 {
    const s = row[1..]; // Allt efter den första bokstaven.
    const parsed = std.fmt.parseInt(i32, s, 10);
    return parsed;
}

fn getDirection(s: []const u8) !Direction {
    if (s.len == 0) {
        return Direction.UNKNOWN;
    }
    const first_char = s[0];
    if (first_char == 'L') {
        return Direction.LEFT;
    } else if (first_char == 'R') {
        return Direction.RIGHT;
    } else {
        return Direction.UNKNOWN;
    }
}

test "Test rotate_dir function" {
    const left_row = "L18";
    const right_row = "R56";
    const empty_row = "";

    try std.testing.expect(getDirection(left_row) == Direction.LEFT);
    try std.testing.expect(getDirection(right_row) == Direction.RIGHT);
    try std.testing.expect(getDirection(empty_row) == Direction.UNKNOWN);
}

test "Test parseRowInt function" {
    const num_str = "L12345";
    const expected_num: i32 = 12345;

    const parsed_num = try parseInt(num_str);
    try std.testing.expectEqual(expected_num, parsed_num);
}

test "calculate function" {
    const start_value: i32 = 50;

    const new_value_left = try updateDail(start_value, "L20");
    try std.testing.expectEqual(30, new_value_left);

    const new_value_right = try updateDail(start_value, "R30");
    try std.testing.expectEqual(80, new_value_right);

    const new_value_wrap_around_left = try updateDail(10, "L20");
    try std.testing.expectEqual(90, new_value_wrap_around_left);

    const new_value_wrap_around_right = try updateDail(90, "R20");
    try std.testing.expectEqual(10, new_value_wrap_around_right);

    const new_value_hit_zero = try updateDail(10, "L10");
    try std.testing.expectEqual(0, new_value_hit_zero);
}

test "reminder test 1" {
    try std.testing.expectEqual(90, @rem(390, 100));
}

test "reminder test 2" {
    try std.testing.expectEqual(39, @rem(390, 100));
}

test "modulo test 2" {
    try std.testing.expectEqual(39, @mod(100, 100));
}

test "Dail left test 1" {
    const result = dailLeft(10, 20);
    try std.testing.expectEqualDeep(.{ 90, 1 }, result);
}

test "Dail left test 2" {
    const result = dailLeft(10, 120);
    try std.testing.expectEqualDeep(.{ 90, 2 }, result);
}

test "Dail left test 3" {
    const result = dailLeft(10, 390);
    try std.testing.expectEqualDeep(.{ 20, 4 }, result);
}

test "Dail left test 4" {
    const result = dailLeft(40, 10);
    try std.testing.expectEqualDeep(.{ 30, 0 }, result);
}

test "Dail left test 5" {
    const result = dailLeft(30, 210);
    try std.testing.expectEqualDeep(.{ 20, 2 }, result);
}

test "Dail right test 1" {
    const result = dailRight(10, 10);
    try std.testing.expectEqualDeep(.{ 20, 0 }, result);
}

test "Dail right test 2" {
    const result = dailRight(0, 100);
    try std.testing.expectEqualDeep(.{ 0, 1 }, result);
}

test "Dail right test 3" {
    const result = dailRight(50, 100);
    try std.testing.expectEqualDeep(.{ 50, 1 }, result);
}

test "Dail right test 4" {
    const result = dailRight(50, 390);
    try std.testing.expectEqualDeep(.{ 40, 4 }, result);
}

test "Multi dail" {
    var passes: i32 = 0;
    const result1 = dailRight(50, 50);
    passes = passes + result1[1];
    const result2 = dailRight(result1[0], 50);
    passes = passes + result2[1];
    try std.testing.expectEqual(1, passes);
    const result3 = dailLeft(result2[0], 50);
    passes = passes + result3[1];
    try std.testing.expectEqual(2, passes);
    const result4 = dailLeft(result3[0], 50);
    passes = passes + result4[1];
    try std.testing.expectEqual(2, passes);
}
