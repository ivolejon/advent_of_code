const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;

const Error = error{
    InvalidFormat,
};

const Ribbon = struct {
    dim1: u32,
    dim2: u32,
    dim3: u32,

    pub fn fromString(s: []const u8) !Ribbon {
        var dims_it = std.mem.tokenizeScalar(u8, s, 'x');
        const dim1_str = dims_it.next() orelse return error.InvalidFormat;
        const dim2_str = dims_it.next() orelse return error.InvalidFormat;
        const dim3_str = dims_it.next() orelse return error.InvalidFormat;

        const dim1 = try std.fmt.parseInt(u32, dim1_str, 10);
        const dim2 = try std.fmt.parseInt(u32, dim2_str, 10);
        const dim3 = try std.fmt.parseInt(u32, dim3_str, 10);

        return Ribbon{
            .dim1 = dim1,
            .dim2 = dim2,
            .dim3 = dim3,
        };
    }
    pub fn getRibbonLength(self: Ribbon) u32 {
        var dims: [3]u32 = .{ self.dim1, self.dim2, self.dim3 };
        std.mem.sort(u32, &dims, {}, comptime std.sort.asc(u32));
        const ribbon_len = (dims[0] + dims[0]) + (dims[1] + dims[1]);
        const bow_len = dims[0] * dims[1] * dims[2];
        return ribbon_len + bow_len;
    }
};

pub fn solution() !void {
    var total_length_of_ribbon: u32 = 0;
    const data = try util.readFile(std.heap.page_allocator, "src/data/2015_2_I_was_told_there_would_be_no_math.txt");
    var it = std.mem.tokenizeScalar(u8, data, '\n'); // 34x65x78
    while (it.next()) |row| {
        print("{s}:", .{row});
        const ribbon = try Ribbon.fromString(row);
        const length = ribbon.getRibbonLength();
        print(" {d}\n", .{length});
        total_length_of_ribbon = total_length_of_ribbon + length;
    }
    print("Total length of ribbon: {d}\n", .{total_length_of_ribbon});
}

test "Ribbon fromString works" {
    const ribbon = try Ribbon.fromString("34x65x78");
    try std.testing.expect(ribbon.dim1 == 34);
    try std.testing.expect(ribbon.dim2 == 65);
    try std.testing.expect(ribbon.dim3 == 78);
}

test "Ribbon length 1" {
    const ribbon = try Ribbon.fromString("2x3x4");
    const length = ribbon.getRibbonLength();
    try std.testing.expect(length == 34);
}

test "Ribbon length 2" {
    const ribbon = try Ribbon.fromString("1x1x10");
    const length = ribbon.getRibbonLength();
    try std.testing.expect(length == 14);
}
