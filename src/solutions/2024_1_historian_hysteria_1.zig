const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;

pub fn solution() !void {
    const gpa = std.heap.page_allocator;

    const arrays = try parseData(gpa);
    const array_one = @field(arrays, "a1");
    const array_two = @field(arrays, "a2");

    var array_distance: [array_one.len]i32 = .{0} ** array_one.len;

    const sorted_one = try sortSliceAsc(gpa, &array_one);
    const sorted_two = try sortSliceAsc(gpa, &array_two);

    for (array_distance, 0..) |_, index| {
        array_distance[index] = calcDistance(sorted_one[index], sorted_two[index]);
    }

    const total_distance = sumSlice(&array_distance);

    print("Sorted Array One: {any}\n", .{sorted_one});
    print("Sorted Array Two: {any}\n", .{sorted_two});
    print("Distance Array: {any}\n", .{array_distance});
    print("Total Distance: {any}\n", .{total_distance});

    // Correct answer is 1222801
}

pub fn parseData(allocator: std.mem.Allocator) !struct { a1: [1000]i32, a2: [1000]i32 } {
    var array_one: [1000]i32 = undefined; // known len
    var array_two: [1000]i32 = undefined;

    const data = try util.readFile(allocator, "src/data/2024_1_historian_hysteria.txt");
    var it = std.mem.tokenizeScalar(u8, data, '\n');
    var i: usize = 0;
    while (it.next()) |row| {
        var it2 = std.mem.splitSequence(u8, row, "   ");
        const first_str = it2.next() orelse continue;
        const second_str = it2.next() orelse continue;
        const first_num = try std.fmt.parseInt(i32, first_str, 10);
        const second_num = try std.fmt.parseInt(i32, second_str, 10);
        array_one[i] = first_num;
        array_two[i] = second_num;
        i = i + 1;
    }
    return .{ .a1 = array_one, .a2 = array_two };
}

fn sortSliceAsc(allocator: std.mem.Allocator, arr: []const i32) ![]i32 {
    const sorted_slice = try allocator.dupe(i32, arr);
    std.mem.sort(i32, sorted_slice, {}, comptime std.sort.asc(i32));
    return sorted_slice;
}

fn calcDistance(num1: i32, num2: i32) i32 {
    return @intCast(@abs(num1 - num2));
}

fn sumSlice(arr: []const i32) i32 {
    var sum: i32 = 0;
    for (arr) |value| {
        sum += value;
    }
    return sum;
}

test "Test sort function asc" {
    const gpa = std.testing.allocator;
    var array_one = [6]i32{ 3, 4, 2, 1, 3, 4 };
    var expected = [6]i32{ 1, 2, 3, 3, 4, 4 };
    const sorted = sortSliceAsc(gpa, &array_one);
    defer gpa.free(sorted);
    try std.testing.expectEqualSlices(i32, &expected, sorted);
}

test "Distance fn" {
    const result = calcDistance(5, 10);
    try std.testing.expectEqual(@as(i32, 5), result);
}

test "Sum slice fn" {
    var array = [5]i32{ 1, 2, 3, 4, 5 };
    const result = sumSlice(&array);
    try std.testing.expectEqual(@as(i32, 15), result);
}
