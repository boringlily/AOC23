const std = @import("std");
const expect = std.testing.expect;
const arrayList = std.ArrayList;

const demo_file = @embedFile("demo.txt");
const input_file = @embedFile("input.txt");

const input_type = enum { num, sym };
const PartNumber = struct {


}

fn solve(file: []const u8) !u64 {
    var readIter = std.mem.tokenize(u8, file, "\n");
    var sum: u64 = 0;
    while (readIter.next()) |line| {
        for (line, 0..) |c, i| {
            std.debug.print("\n{d} -- {c}", .{ i, c });
        }
        std.debug.print("\n ", .{});
    }
    std.debug.print("\nSum of possible games: {d}\n", .{sum});

    return sum;
}

pub fn main() !void {
    _ = try solve(input_file);
}

test "demo" {
    if (solve(demo_file)) |value| {
        try expect(value == 4361);
    } else |err| {
        _ = err catch {};
    }
}
