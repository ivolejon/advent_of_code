const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const splitSequence = std.mem.splitSequence;
const trim = std.mem.trim;
const Allocator = std.mem.Allocator;

const Box = struct {
    id: usize,
    x: f32,
    y: f32,
    z: f32,
    pub fn init(input: []const u8, id: usize) !Box {
        var it = std.mem.tokenizeScalar(u8, input, ',');
        var coords: [3]f32 = [_]f32{0} ** 3;
        var index: usize = 0;
        while (it.next()) |part| {
            coords[index] = try std.fmt.parseFloat(f32, part);
            index += 1;
        }
        return Box{
            .id = id,
            .x = coords[0],
            .y = coords[1],
            .z = coords[2],
        };
    }
};

const Edge = struct {
    from: usize,
    to: usize,
    distance: f64,
};

pub fn solution() !void {
    const allocator = std.heap.page_allocator;
    const data = try util.readFile(allocator, "src/data/2025_8_playground.txt");
    defer {
        allocator.free(data);
    }

    var boxes: ArrayList(Box) = .empty;
    var edges: ArrayList(Edge) = .empty;

    var it = std.mem.tokenizeScalar(u8, data, '\n');

    var h: usize = 0;
    while (it.next()) |row| {
        const b = try Box.init(row, h);
        try boxes.append(allocator, b);
        h += 1;
    }

    // defer {
    //     for (boxes.items) |b| {
    //         allocator.free(b);
    //     }
    // }
    const num_boxes = boxes.items.len;
    for (0..num_boxes) |i| {
        const b1 = boxes.items[i];

        for (i + 1..num_boxes) |j| {
            const b2 = boxes.items[j];
            const dist_sq = distance_squared_3d(b1, b2);

            const edge: Edge = .{
                .from = b1.id,
                .to = b2.id,
                .distance = dist_sq,
            };

            try edges.append(allocator, edge);
        }
    }

    const typeof = @TypeOf(edges.items[0]);
    std.mem.sort(typeof, edges.items, {}, lessThanFn);

    // Print edges
    for (edges.items) |e| {
        print("Edge from Box {d} to Box {d}: Distance = {any}\n", .{ e.from, e.to, e.distance });
    }
}

fn lessThanFn(_: void, e1: Edge, e2: Edge) bool {
    return e1.distance < e2.distance;
}

fn distance_squared_3d(b1: Box, b2: Box) f64 {
    const dx: f64 = b2.x - b1.x;
    const dy: f64 = b2.y - b1.y;
    const dz: f64 = b2.z - b1.z;

    return dx * dx + dy * dy + dz * dz; // Ingen std.math.sqrt()
}
