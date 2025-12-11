const std = @import("std");
const Allocator = std.mem.Allocator;
const util = @import("advent_of_code");
const SHMap = std.StringHashMap;
const print = std.debug.print;
const AList = @import("orcz").ManagedArrayList;
const Vec2 = @import("qpEngine").math.Vector(i32, 2);

const Data = struct {
    tiles: AList(Vec2),
};

fn loadData(alloc_: Allocator) !Data {
    const input = try util.readFile(alloc_, "src/data/2025_9_movie_theater.txt");
    const content = std.mem.trimRight(u8, input, "\n");

    var data: Data = .{
        .tiles = .init(alloc_),
    };
    var rows = std.mem.splitSequence(u8, content, "\n");
    while (rows.next()) |row| {
        var components = std.mem.tokenizeScalar(u8, row, ',');
        try data.tiles.append(Vec2.from(.{
            try std.fmt.parseInt(i32, components.next().?, 10),
            try std.fmt.parseInt(i32, components.next().?, 10),
        }));
    }

    // try printData(data);

    return data;
}

fn printData(data_: Data) !void {
    for (data_.tiles.items()) |tile| {
        std.debug.print("{any}\n", .{tile});
    }
}

const TPair = struct {
    a: usize,
    b: usize,
    c: u64,

    pub fn compare(ctx_: @TypeOf(.{}), lhs: TPair, rhs: TPair) bool {
        _ = ctx_;
        return lhs.c > rhs.c;
    }
};

pub fn solve(alloc_: Allocator, data_: Data) !void {
    var max_area: u64 = 0;
    var bounds: AList(TPair) = .init(alloc_);
    for (0..data_.tiles.len() - 1) |i| {
        for (i + 1..data_.tiles.len()) |j| {
            var s = data_.tiles.items()[i];
            var o = data_.tiles.items()[j];
            try bounds.append(.{
                .a = i,
                .b = j,
                .c = s.content(u64, o.summated(o.subtracted(s).signed())),
            });
        }
    }
    std.mem.sort(TPair, bounds.items(), .{}, TPair.compare);

    var lines: AList(TPair) = .init(alloc_);
    for (0..data_.tiles.len()) |i| {
        try lines.append(.{
            .a = i,
            .b = (i + 1) % data_.tiles.len(),
            .c = 0,
        });
    }

    blk: for (bounds.items()) |b| {
        var s = data_.tiles.items()[b.a];
        const o = data_.tiles.items()[b.b];
        const min = s.minimumOfed(o).ptr().summated(.{ 1, 1 });
        const max = s.maximumOfed(o).ptr().subtracted(.{ 1, 1 });
        for (lines.items()) |l| {
            var p1 = data_.tiles.items()[l.a];
            const p2 = data_.tiles.items()[l.b];
            const seg_min = p1.minimumOfed(p2);
            const seg_max = p1.maximumOfed(p2);
            const outside = @reduce(.Or, seg_max.lesser(min)) or @reduce(.Or, seg_min.greater(max));

            if (!outside) continue :blk;
        }

        max_area = b.c;
        break :blk;
    }

    print("Hej, max area is {d}\n", .{max_area});
}

pub fn solution() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.smp_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try loadData(allocator);

    try solve(allocator, data);
}
