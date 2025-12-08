const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const splitSequence = std.mem.splitSequence;
const trim = std.mem.trim;
const AutoHashMap = std.AutoHashMap;

const dims: usize = 142; // 142
var base_matrix: [dims][dims]u8 = undefined;
var transposed_base_matrix: @TypeOf(base_matrix) = undefined;

pub fn solution() !void {
    var bank: [dims]i32 = [_]i32{0} ** dims;
    var mul: [dims]i32 = [_]i32{-1} ** dims;
    const allocator = std.heap.page_allocator;

    const data = try util.readFile(allocator, "src/data/2025_7_laboratories.txt");
    defer {
        allocator.free(data);
    }

    var it = std.mem.tokenizeScalar(u8, data, '\n');

    var h: usize = 0;
    while (it.next()) |row| {
        for (row, 0..) |char, index| {
            base_matrix[h][index] = char;
        }
        h += 1;
    }

    var timelines: i32 = 0;

    for (base_matrix) |row| {
        for (row, 0..) |cell, j| {
            if (cell == 'S') {
                bank[j] = 1;
            }

            if (cell == '^') {
                const v: i32 = bank[j];
                bank[j] = 0;
                if (j >= 0) {
                    const new_val = bank[j - 1] + v;
                    bank[j - 1] = new_val;
                    if (new_val > 9) {
                        var rest = @mod(new_val, 10);
                        var kvot = @rem(new_val, 10);
                        if (rest == 0 and kvot == 0) { // Det är 10
                            kvot = 1;
                            rest = 0;
                        }
                        bank[j - 1] = kvot;
                        mul[j - 1] = rest;
                    }
                }
                if (j <= dims) {
                    const new_val = bank[j + 1] + v;
                    bank[j + 1] = new_val;
                    if (new_val > 9) {
                        var rest = @mod(new_val, 10);
                        var kvot = @rem(new_val, 10);
                        if (rest == 0 and kvot == 0) { // Det är 10
                            kvot = 1;
                            rest = 0;
                        }
                        bank[j + 1] = kvot;
                        mul[j + 1] = rest;
                    }
                }
            }
        }
    }

    printGrid(&base_matrix);
    print("{any}\n", .{bank});
    print("{any}\n", .{mul});

    for (bank, 0..) |num, i| {
        const multiplier = mul[i];
        var col_value: i32 = 0;
        if (multiplier > -1) {
            const str = try std.fmt.allocPrint(
                std.heap.page_allocator,
                "{d}{d}",
                .{ num, multiplier },
            );
            col_value = std.fmt.parseInt(i32, str, 10) catch |err| {
                print("Error parsing int from string {s}: {any}\n", .{ str, err });
                return err;
            };
        } else {
            col_value = num;
        }
        timelines += col_value;
    }

    print("Timelines: {d}\n", .{timelines});
}

fn printGrid(matrix: *@TypeOf(base_matrix)) void {
    for (matrix) |row| {
        for (row) |cell| {
            print("{c}", .{cell});
        }
        print("\n", .{});
    }
}
