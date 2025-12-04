const std = @import("std");
const print = std.debug.print;
const util = @import("advent_of_code");

pub fn solution() !void {
    var floor: i32 = 0;
    const data = try util.readFile(std.heap.page_allocator, "src/data/2015_1_not_quite_lisp.txt");
    for (data) |byte| {
        print("{any}\n\n", .{byte});
        if (byte == '(') {
            floor = floor + 1;
        } else if (byte == ')') {
            floor = floor - 1;
        }
    }
    print("Final floor: {d}\n", .{floor});
}
