const std = @import("std");
const print = std.debug.print;
const util = @import("advent_of_code");

pub fn solution() !void {
    var floor: i32 = 0;
    var basement: usize = undefined;
    const data = try util.readFile(std.heap.page_allocator, "src/data/2015_1_not_quite_lisp.txt");
    for (data, 0..) |byte, index| {
        if (byte == '(') {
            floor = floor + 1;
        } else if (byte == ')') {
            floor = floor - 1;
            if (floor == -1) {
                basement = index + 1; // +1 för att få rätt position (1-baserad)
                print("Causes him to enter the basement: {d}", .{basement});
                break;
            }
        }
    }
}
