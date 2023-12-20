const std = @import("std");
const expect = std.testing.expect;
const arrayList = std.ArrayList;

const demo_file = @embedFile("demo.txt");
const input_file = @embedFile("input.txt");

const Cubes = struct {
    r: ?u8,
    g: ?u8,
    b: ?u8,
};

pub fn parseGameLine(str: []const u8, compare: *const Cubes) !u32 {
    _ = compare;
    std.debug.print("\n{s} --- {d}", .{ str, str.len });
    var splitSpaces = std.mem.tokenize(u8, str, " ");
    var token_count: u32 = 0;
    while (splitSpaces.next()) |token| : (token_count += 1) {
        if (token_count < 2) continue;
        std.debug.print("\n {d} [{s}]", .{ token_count, token });
    }

    return 0;
}

fn possibleGames(file: []const u8, compareCubes: Cubes) !u32 {
    var readIter = std.mem.tokenize(u8, file, "\n");
    var sum: u32 = 0;
    while (readIter.next()) |line| {
        sum += try parseGameLine(line, &compareCubes);
    }
    std.debug.print("\nSum of possible games: {d}\n", .{sum});

    return sum;
}

pub fn main() !void {
    const input_cubes = Cubes{ .r = 12, .g = 13, .b = 14 };
    possibleGames(input_file, input_cubes);
}

test "demo" {
    const demo_cube = Cubes{ .r = 12, .g = 13, .b = 14 };
    if (possibleGames(demo_file, demo_cube)) |value| {
        try expect(value == 8);
    } else |err| {
        _ = err catch {};
    }
}
