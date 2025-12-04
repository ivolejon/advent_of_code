const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;
var counter: u32 = 10000;
var total_rolls: u32 = 0;
pub var bounds: u16 = 135;

pub fn solution() !void {

    // var x : usize = 0;
    var j: usize = 0;
    var matrix: [135][135]u16 = undefined;
    var matrix_updated: [135][135]u16 = undefined;

    const data = try util.readFile(std.heap.page_allocator, "src/data/2025_4_printing_department.txt");
    var it = std.mem.tokenizeScalar(u8, data, '\n');
    while (it.next()) |row| {
        for (row, 0..) |char, index| {
            matrix[j][index] = char;
        }
        j += 1;
    }

    const Pos = [2]i8; // Rad, Column
    const positions: [8]Pos = .{
        .{ -1, -1 }, // Up-Left
        .{ 0, -1 }, // Up
        .{ 1, -1 }, // Up-Right
        .{ 1, 0 }, // Right
        .{ 1, 1 }, // Down-Right
        .{ 0, 1 }, // Down
        .{ -1, 1 }, // Down-Left
        .{ -1, 0 }, // Left
    };

    while (counter > 0) {
        counter = 0;
        for (matrix, 0..) |row, r| {
            for (row, 0..) |c, i| {
                var number_of_rolls_around: u8 = 0;
                matrix_updated[r][i] = matrix[r][i];
                if (c == '.') {
                    continue;
                }
                const x = ToI16(r);
                const y = ToI16(i);

                // Look around;
                for (positions) |pos| {
                    const look_at = .{ x + pos[0], y + pos[1] };

                    // Out of bounds
                    if (!isValidPosition(look_at[0], look_at[1])) {
                        continue;
                    }

                    // Found log
                    if (matrix[ToUsize(look_at[0])][ToUsize(look_at[1])] == '@') {
                        number_of_rolls_around += 1;
                    }
                }
                // If number of rolls around is < 4 then bingo
                if (number_of_rolls_around < 4) {
                    matrix_updated[ToUsize(x)][ToUsize(y)] = '.';
                    counter += 1;
                }
            }
        }
        matrix = matrix_updated;
        // printGrid(matrix);
        total_rolls = total_rolls + counter;
        print("\nTotal: {d}", .{counter});
    }
    print("Final total rolls: {d}\n", .{total_rolls});
}

fn isValidPosition(x: i16, y: i16) bool {
    if (x < 0 or y < 0 or x > ToI16(bounds - 1) or y > ToI16(bounds - 1)) {
        return false;
    }
    return true;
}

fn ToI16(value: usize) i16 {
    return @as(i16, @intCast(value));
}

fn ToUsize(value: i16) usize {
    if (value < 0) {
        return 0;
    }
    return @as(usize, @intCast(value));
}

fn printGrid(matrix: [135][135]u16) void {
    for (matrix) |row| {
        for (row) |cell| {
            const s = [_]u16{cell};
            var utf8_buffer_out: [1]u8 = undefined;
            const decoded_utf8_len = std.unicode.utf16LeToUtf8(utf8_buffer_out[0..], &s) catch unreachable;
            const decoded_utf8_slice = utf8_buffer_out[0..decoded_utf8_len];
            print("{s}", .{decoded_utf8_slice});
        }
        print("\n", .{});
    }
}

test "isNonValidPosition test" {
    try std.testing.expect(isValidPosition(5, 5) == true);
    try std.testing.expect(isValidPosition(-1, 5) == false);
    try std.testing.expect(isValidPosition(5, -1) == false);
    try std.testing.expect(isValidPosition(135, 5) == false);
    try std.testing.expect(isValidPosition(5, 135) == false);
}
