const std = @import("std");
const util = @import("advent_of_code");
const parseData = @import("2024_1_historian_hysteria_1.zig").parseData;

pub fn solution() !void {
    const gpa = std.heap.page_allocator;

    const arrays = try parseData(gpa);
    const needles = @field(arrays, "a1");
    const haystack = @field(arrays, "a2");

    var frequency: [needles.len]i32 = undefined;

    for (needles, 0..) |needle, index| {
        frequency[index] = count_frequency(@constCast(&haystack), needle);
    }

    const calculations = try calc_frequency_sum(gpa, &needles, &frequency);
    defer gpa.free(calculations);

    var sum_of_all_calculations: i32 = 0;
    for (calculations) |value| {
        sum_of_all_calculations += value;
    }

    std.debug.print("Sum of all calculations: {any}\n", .{sum_of_all_calculations});
}

fn count_frequency(haystack: []i32, needle: i32) i32 {
    var count: i32 = 0;
    for (
        haystack,
    ) |number| {
        if (number == needle) {
            count += 1;
        }
    }
    return count;
}

fn calc_frequency_sum(allocator: std.mem.Allocator, needles: []const i32, frequency: []const i32) ![]const i32 {
    var sums: []i32 = try allocator.alloc(i32, needles.len);
    for (needles, 0..) |_, index| {
        sums[index] = needles[index] * frequency[index];
    }
    return sums;
}

test "Test count occurrences" {
    const haystack = [_]i32{ 1, 2, 3, 2, 4, 2, 5 };
    const needle = 2;
    const expected_count = 3;
    const actual_count = count_frequency(@constCast(&haystack), needle);
    try std.testing.expectEqual(actual_count, expected_count);
}

test "Test calc_frequency_sum" {
    const gpa = std.testing.allocator;
    const needles = [_]i32{ 1, 2, 3 };
    const frequency = [_]i32{ 3, 2, 1 };
    const expected_slice: []const i32 = &[_]i32{ 3, 4, 3 };
    const actual_sums = try calc_frequency_sum(gpa, &needles, &frequency);
    defer gpa.free(actual_sums);
    try std.testing.expectEqualSlices(i32, expected_slice, actual_sums);
}
