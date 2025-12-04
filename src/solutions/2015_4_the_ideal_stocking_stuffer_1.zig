const std = @import("std");
const print = std.debug.print;

pub fn solution() !void {
    const input = "ckczppom";
    var md5_hash: [16]u8 = undefined;
    var counter: u32 = 0;

    while (true) {
        print("Trying number: {d}\n", .{counter});
        const str = try std.fmt.allocPrint(std.heap.page_allocator, "{s}{d}", .{ input, counter });
        std.crypto.hash.Md5.hash(str, md5_hash[0..], .{});
        if (md5_hash[0] == 0 and md5_hash[1] == 0 and (md5_hash[2] & 0xF0) == 0) {
            print("Found number: {d}\n", .{counter});
            break;
        }
        counter += 1;
    }
}
