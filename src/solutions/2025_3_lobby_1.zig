const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;

pub var pointer: usize = 0;
pub var v1: usize = 0;
pub var v2: usize = 0;
pub var vp: usize = 0;
pub var sum: usize = 0;

pub fn solution() !void {
    const data = try util.readFile(std.heap.page_allocator, "src/data/2025_3_lobby.txt");
    var it = std.mem.tokenizeScalar(u8, data, '\n');
    while (it.next()) |row| {
        pointer = 0;
        v1 = 0;
        v2 = 0;
        vp = 0;
        // Loop over chars first time and store the index of the highest number 1-9
        for (row, 0..) |_, index| {
            pointer = index;
            // print("pointer: {d}\n", .{pointer});
            if (index == row.len - 1) {
                break;
            }
            const digit_slice = [_]u8{row[pointer]};
            const valueAtPointer = try std.fmt.parseInt(usize, digit_slice[0..1], 10);
            if (valueAtPointer == 9) {
                v1 = valueAtPointer;
                vp = pointer;
                break;
            }
            if (valueAtPointer > v1) {
                v1 = valueAtPointer;
                vp = pointer;
            }
        }

        // Loop over chars second time starting from pointer and find next highest number
        for (row, 0..) |_, index| {
            if (index <= vp) {
                continue;
            }
            pointer = index;
            const digit_slice = [_]u8{row[pointer]};
            const valueAtPointer = try std.fmt.parseInt(usize, digit_slice[0..1], 10);
            if (valueAtPointer == 9) {
                v2 = valueAtPointer;
                vp = pointer;
                break;
            }
            if (valueAtPointer > v2) {
                v2 = valueAtPointer;
                vp = pointer;
            }
        }

        const str = try std.fmt.allocPrint(
            std.heap.page_allocator,
            "{d}{d}",
            .{ v1, v2 },
        );
        const val = try std.fmt.parseInt(usize, str[0..], 10);
        sum = sum + val;
    }
    print("Sum: {d}\n", .{sum});
}
