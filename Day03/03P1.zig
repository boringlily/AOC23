const std = @import("std");
const expect = std.testing.expect;
const arrayList = std.ArrayList;

const demo_file = @embedFile("demo.txt");
const input_file = @embedFile("input.txt");

pub fn parseLine(str: []const u8) !u64 {
    _ = str;
    return 0;
}

fn solve(file: []const u8) !u64 {
    var readIter = std.mem.tokenize(u8, file, "\n");
    var sum: u64 = 0;
    while (readIter.next()) |line| {
        sum += try parseLine(line);
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
