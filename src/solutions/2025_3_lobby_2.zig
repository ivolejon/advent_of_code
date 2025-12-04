const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;
pub var sum: usize = 0;
pub fn solution() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const data = try util.readFile(std.heap.page_allocator, "src/data/2025_3_lobby.txt");
    var it = std.mem.tokenizeScalar(u8, data, '\n');
    while (it.next()) |row| {
        var batteries: [100]u8 = undefined; // Varje rad innehåller 100 chars
        for (row, 0..) |_, index| {
            batteries[index] = row[index];
        }

        var seq = try find_max_subsequence(allocator, batteries[0..row.len], 12);
        defer seq.deinit(allocator);
        var value_str: [12]u8 = undefined;
        for (seq.items, 0..) |digit, index| {
            value_str[index] = digit;
        }
        sum = sum + (try std.fmt.parseInt(usize, value_str[0..12], 10));
    }
    print("Sum: {d}\n", .{sum});
}

fn find_max_subsequence(
    allocator: std.mem.Allocator,
    bank: []const u8,
    target_len: usize,
) !std.ArrayList(u8) {
    const total_len = bank.len;
    // Antal siffror som måste tas bort
    var to_remove: isize = @as(isize, @intCast(total_len)) - @as(isize, @intCast(target_len));
    print("To remove: {d}\n", .{to_remove});
    var result: std.ArrayList(u8) = .empty;
    var current_index: usize = 0;

    while (result.items.len < target_len) {
        const needed = target_len - result.items.len;

        const max_search_index = total_len - needed;

        var best_digit: u8 = 0;
        var best_index: usize = current_index;

        // Girig sökning: hitta den största siffran i det tillåtna fönstret
        var search_index = current_index;
        while (search_index <= max_search_index) : (search_index += 1) {
            const digit = bank[search_index];
            if (digit > best_digit) {
                best_digit = digit;
                best_index = search_index;
                // Om vi hittar '9', kan vi inte hitta något bättre.
                if (best_digit == '9') break;
            }
        }

        //* Beräkna hur många siffror som faktiskt togs bort i detta steg
        const removed_count = @as(isize, @intCast(best_index)) - @as(isize, @intCast(current_index));
        to_remove -= removed_count;

        try result.append(allocator, best_digit);

        current_index = best_index + 1;
    }

    return result;
}

test "find_max_subsequence test 1" {
    const a = std.testing.allocator;
    const bank: [15]u8 = [_]u8{ '8', '1', '8', '1', '8', '1', '9', '1', '1', '1', '2', '1', '1', '1', '1' };
    var res = try find_max_subsequence(a, bank[0..], 12);
    defer res.deinit(a);
    const expected: [12]u8 = [_]u8{ '8', '8', '8', '9', '1', '1', '1', '2', '1', '1', '1', '1' };
    try std.testing.expectEqualSlices(u8, res.items, &expected);
}
