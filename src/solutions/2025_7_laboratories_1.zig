const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const splitSequence = std.mem.splitSequence;
const trim = std.mem.trim;

const dims = 142;
var base_matrix: [dims][dims]u8 = undefined;

pub fn solution() !void {
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

    start(&base_matrix);
    var splits: u32 = 0;

    var index: usize = 0;

    while (index < dims) {
        for (base_matrix, 0..) |row, i| {
            if (i == dims - 1) break;
            for (row, 0..) |cell, j| {
                // I have been here already!
                if (cell == '|' and base_matrix[i + 1][j] == '^' and base_matrix[i + 1][j - 1] == '|' and base_matrix[i + 1][j + 1] == '|') {
                    break;
                }

                if (cell == '|' and base_matrix[i + 1][j] == '^') {
                    base_matrix[i + 1][j - 1] = '|';
                    base_matrix[i + 1][j + 1] = '|';
                    splits += 1;
                } else if (cell == '|' and base_matrix[i + 1][j] == '.') {
                    base_matrix[i + 1][j] = '|';
                }
            }
        }
        index += 1;
        printGrid(&base_matrix);
    }
    print("Broke: {d}\n", .{splits});
}

fn printGrid(matrix: *@TypeOf(base_matrix)) void {
    for (matrix) |row| {
        for (row) |cell| {
            print("{c}", .{cell});
        }
        print("\n", .{});
    }
}

fn start(matrix: *@TypeOf(base_matrix)) void {
    for (matrix, 0..) |row, i| {
        for (row, 0..) |cell, j| {
            if (cell == 'S') {
                matrix[i + 1][j] = '|'; // Row below!
                return;
            }
        }
    }
    std.debug.panic("Should find 'S'", .{});
}
