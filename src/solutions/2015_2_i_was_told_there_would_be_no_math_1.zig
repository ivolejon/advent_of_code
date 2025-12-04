const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;

const Error = error{InvalidFormat};

const Present = struct {
    dim1: u32,
    dim2: u32,
    dim3: u32,

    pub fn fromString(s: []const u8) !Present {
        var dims_it = std.mem.tokenizeScalar(u8, s, 'x');
        const dim1_str = dims_it.next() orelse return error.InvalidFormat;
        const dim2_str = dims_it.next() orelse return error.InvalidFormat;
        const dim3_str = dims_it.next() orelse return error.InvalidFormat;

        const dim1 = try std.fmt.parseInt(u32, dim1_str, 10);
        const dim2 = try std.fmt.parseInt(u32, dim2_str, 10);
        const dim3 = try std.fmt.parseInt(u32, dim3_str, 10);

        return Present{
            .dim1 = dim1,
            .dim2 = dim2,
            .dim3 = dim3,
        };
    }
    pub fn getSmallestDimension(self: Present) u32 {
        return std.math.min(std.math.min(self.dim1, self.dim2), self.dim3);
    }
    pub fn totalArea(self: Present) u32 {
        const area1 = self.dim1 * self.dim2;
        const area2 = self.dim2 * self.dim3;
        const area3 = self.dim1 * self.dim3;
        const smallest_area = @min(@min(area1, area2), area3);
        return 2 * (area1 + area2 + area3) + smallest_area;
    }
};

pub fn solution() !void {
    var total_area_of_wrapping: u32 = 0;
    const data = try util.readFile(std.heap.page_allocator, "src/data/2015_2_I_was_told_there_would_be_no_math.txt");
    var it = std.mem.tokenizeScalar(u8, data, '\n'); // 34x65x78
    while (it.next()) |row| {
        print("{s}:", .{row});
        const present = try Present.fromString(row);
        const area = present.totalArea();
        print(" {d}\n", .{area});
        total_area_of_wrapping = total_area_of_wrapping + area;
    }
    print("Total area of wrapping: {d}\n", .{total_area_of_wrapping});
}

test "Present fromString works" {
    const present = try Present.fromString("34x65x78");
    try std.testing.expect(present.dim1 == 34);
    try std.testing.expect(present.dim2 == 65);
    try std.testing.expect(present.dim3 == 78);
}

test "Total area 1" {
    const present = try Present.fromString("2x3x4");
    const area = present.totalArea();
    try std.testing.expect(area == 58);
}

test "Total area 2" {
    const present = try Present.fromString("1x1x10");
    const area = present.totalArea();
    try std.testing.expect(area == 43);
}
