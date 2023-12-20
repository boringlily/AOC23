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

fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

pub fn parseGameLine(str: []const u8, compare: *const Cubes) !u32 {
    // std.debug.print("\n{s} --- {d}", .{ str, str.len });
    var splitSpaces = std.mem.tokenize(u8, str, " ");
    var token_count: u32 = 0;
    var number: u8 = 0;
    var gameNum: u32 = 0;
    var maxCubes = Cubes{
        .r = 0,
        .g = 0,
        .b = 0,
    };
    while (splitSpaces.next()) |token| : (token_count += 1) {
        if (token_count == 0) continue;
        if (token_count == 1) {
            gameNum = try std.fmt.parseInt(u8, token[0 .. token.len - 1], 10);
            continue;
        }
        if ((token_count % 2) == 0)
            number = try std.fmt.parseInt(u8, token, 10);
        if ((token_count % 2) == 1) {
            switch (token[0]) {
                'r' => {
                    maxCubes.r = max(u8, maxCubes.r.?, number);
                },
                'g' => {
                    maxCubes.g = max(u8, maxCubes.g.?, number);
                },
                'b' => {
                    maxCubes.b = max(u8, maxCubes.b.?, number);
                },
                else => {},
            }
        }
    }
    const passed: bool = (maxCubes.r.? <= compare.r.?) and (maxCubes.g.? <= compare.g.?) and (maxCubes.b.? <= compare.b.?);
    std.debug.print("\n gameNum:{d} [{d},{d},{d}] -- {any}", .{ gameNum, maxCubes.r.?, maxCubes.g.?, maxCubes.b.?, passed });

    return if (passed) gameNum else 0;
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
    _ = try possibleGames(input_file, input_cubes);
}

test "demo" {
    const demo_cube = Cubes{ .r = 12, .g = 13, .b = 14 };
    if (possibleGames(demo_file, demo_cube)) |value| {
        try expect(value == 8);
    } else |err| {
        _ = err catch {};
    }
}
