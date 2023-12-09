const std = @import("std");
const expect = std.testing.expect;

const puzzle_input = @embedFile("input.txt");
const demo_input1 = @embedFile("demo1.txt");
const demo_input2 = @embedFile("demo2.txt");

fn solve(file_content: []const u8) ?u32 {
    _ = file_content;
    return null;
}

pub fn main() !void {
    return;
}

test "demo inputs" {
    try expect(solve(demo_input1).? == 2);
    try expect(solve(demo_input2).? == 6);
}
