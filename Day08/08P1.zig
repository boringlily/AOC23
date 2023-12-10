const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

const puzzle_input = @embedFile("input.txt");
const demo_input1 = @embedFile("demo1.txt");
const demo_input2 = @embedFile("demo2.txt");

const Sequence = struct {
    const Self = @This();

    const allocator = std.heap.page_allocator;
    var seq_list = std.ArrayList(u8).init(allocator);
    len: u64 = 0,
    current_position: u64 = 0,
    fn next(self: *Self) u8 {
        const char: u8 = self.sequence[self.current_position];
        if (self.current_position < self.len)
            self.current_position += 1;
        return char;
    }

    pub fn init(self: *Self, in: []const u8) void {
        _ = in;
        _ = self;
    }
};

const Node = struct {
    left: [3]u8,
    right: [3]u8,
};

fn solve(file_content: []const u8) !u32 {
    print("\n\n###### FILE START ######\n", .{});

    const alloc = std.heap.page_allocator;

    var hash_map = std.AutoHashMap(
        [3]u8,
        Node,
    ).init(alloc);

    var readIter = std.mem.tokenize(u8, file_content, "\n");
    var sequence: [300]u8 = undefined;
    var seq_len: u64 = 0;
    var seq_pos: u64 = 0;

    if (readIter.next()) |value| {
        for (value, 0..) |c, index| {
            if (c == 'L' or c == 'R') {
                sequence[index] = c;
                seq_len += 1;
            }
        }
    }
    _ = readIter.next();

    print("\n sequence = {any} \n", .{sequence});

    var i: u64 = 0;
    while (readIter.next()) |line| {
        i += 1;
        const key: [3]u8 = line[0..3].*;
        const value = Node{
            .left = line[7..10].*,
            .right = line[12..15].*,
        };
        print("\n\n {s}", .{line});
        print("\n key: {s} left: {s} right: {s}", .{ key, value.left, value.right });
        try hash_map.put(key, value);
    }
    print("\n\n", .{});
    var current_position = [3]u8{ 'A', 'A', 'A' };
    var steps: u32 = 0;
    while (true) {
        print("\n", .{});
        var next_position: [3]u8 = undefined;

        steps += 1;
        var val: Node = if (hash_map.get(current_position)) |value| value else undefined;
        // if (hash_map.get(current_position)) |value| {
        //     val = value;
        // }

        if (seq_pos >= seq_len) {
            seq_pos = 0;
        }

        const next_pos: u8 = sequence[seq_pos];
        seq_pos += 1;
        if (next_pos == 'L') {
            next_position = val.left;
        } else if (next_pos == 'R') {
            next_position = val.right;
        }

        print("{s}->{s}\n\n", .{ current_position, next_position });
        if (std.meta.eql(next_position, [3]u8{ 'Z', 'Z', 'Z' })) {
            print("\n\n###### STEPS: {d} #####\n\n", .{steps});
            return steps;
        }

        current_position = next_position;
    }

    return 0;
}

pub fn main() !void {
    _ = try solve(puzzle_input);
    return;
}

test "demo inputs" {
    if (solve(demo_input1)) |value| {
        try expect(value == 2);
    } else |err| {
        _ = err catch {};
    }
    if (solve(demo_input2)) |value| {
        try expect(value == 6);
    } else |err| {
        _ = err catch {};
    }
}
