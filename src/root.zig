//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub fn readFile(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    const file_content = try std.fs.cwd().readFileAlloc(allocator, path, std.math.maxInt(usize));
    return file_content;
}
