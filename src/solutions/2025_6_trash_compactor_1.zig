const std = @import("std");
const util = @import("advent_of_code");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const splitSequence = std.mem.splitSequence;
const trim = std.mem.trim;

const Row = ArrayList(Item);
const Operation = enum {
    Add,
    Multiply,
    None,
};
const Item = struct {
    value: i64,
    op: Operation,

    pub fn init(input_val: []const u8) Item {
        var parsed_value: i64 = 0;
        var op: Operation = .None;
        if (std.fmt.parseInt(i64, input_val, 10)) |res| {
            parsed_value = res;
        } else |_| {
            if (std.mem.eql(u8, input_val, "+")) {
                op = .Add;
            } else if (std.mem.eql(u8, input_val, "*")) {
                op = .Multiply;
            }
        }
        return .{ .value = parsed_value, .op = op };
    }

    pub fn create(v: i64, o: Operation) Item {
        return .{ .value = v, .op = o };
    }
};

var final_sum: i64 = 0;

pub fn solution() !void {
    const allocator = std.heap.page_allocator;

    var cols: ArrayList(Row) = .empty;
    defer cols.deinit(allocator);

    const data = try util.readFile(std.heap.page_allocator, "src/data/2025_6_trash_compactor.txt");
    var it = std.mem.tokenizeScalar(u8, data, '\n');
    while (it.next()) |line| {
        var row: Row = .empty;
        var values_it = splitSequence(u8, line, " ");
        while (values_it.next()) |value| {
            const t = trim(u8, value, " ");
            if (!std.mem.eql(u8, t, "")) {
                const item = Item.init(t);
                try row.append(allocator, item);
            }
        }
        try cols.append(allocator, row);
    }

    const col_length = cols.items[0].items.len; // | x | a | b | ...

    // Transpose
    for (0..col_length) |i| {
        var transposed: ArrayList(Item) = .empty;
        for (0..cols.items.len) |j| {
            const item = Item.create(cols.items[j].items[i].value, cols.items[j].items[i].op);
            try transposed.append(allocator, item);
        }
        // Sum up column
        try calculate(&transposed);
        transposed.deinit(allocator);
    }

    // defer cols.deinit(allocator);

    print("Final sum: {d}\n", .{final_sum});
}

fn calculate(list: *ArrayList(Item)) !void {
    var sum: i64 = 0;
    var op: Operation = .None;
    const try_item = list.pop();
    if (try_item) |item| {
        op = item.op;
    }
    if (op == Operation.Multiply) {
        sum = 1;
    }
    for (list.items) |item| {
        print("{d}\n", .{item.value});
        if (op == Operation.Multiply) {
            sum = sum * item.value;
        } else {
            sum = sum + item.value;
        }
    }
    final_sum = final_sum + sum;
    print("Result: {d}\n", .{sum});
}
