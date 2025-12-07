const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const splitSequence = std.mem.splitSequence;
const trim = std.mem.trim;

var final_sum: i64 = 0;
var current_col_sum: ArrayList(i64) = .empty;

pub fn solution() !void {
    const allocator = std.heap.page_allocator;

    var lines: ArrayList([]const u8) = .empty;
    defer lines.deinit(allocator);

    const data = try util.readFile(std.heap.page_allocator, "src/data/2025_6_trash_compactor.txt");
    var it = std.mem.tokenizeScalar(u8, data, '\n');
    while (it.next()) |line| {
        try lines.append(allocator, line);
    }
    const line_length: usize = lines.items[0].len; // How many chars
    var i = line_length;
    while (i > 0) {
        var columns: ArrayList(u8) = .empty;
        var operation: u8 = 'u';
        i = i - 1;
        for (lines.items) |line| {
            var value: u8 = ' ';
            if (i <= line.len - 1) {
                value = line[i];
            }
            try columns.append(allocator, value);
            if (value == '*' or value == '+') {
                operation = value;
            }
        }
        try calculate(allocator, columns, operation);
    }
    print("Final sum: {d}\n", .{final_sum});
}

fn calculate(allocator: std.mem.Allocator, column_values: ArrayList(u8), operation: u8) !void {
    var sum: i64 = 0;
    const try_num = std.fmt.parseInt(i64, std.mem.trim(u8, column_values.items, " u*+"), 10);
    if (try_num) |num| {
        try current_col_sum.append(allocator, num);
    } else |_| {}

    // Column in done, calculate
    if (operation == '*' or operation == '+') {
        if (operation == '*') {
            sum = 1;
        }

        for (current_col_sum.items) |number| {
            if (operation == '*') {
                sum = sum * number;
            } else {
                sum = sum + number;
            }
        }
        final_sum = final_sum + sum;
        current_col_sum = .empty;
        return;
    }
}
