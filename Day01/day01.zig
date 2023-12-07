const std = @import("std");
const expect = std.testing.expect;


fn getCalibrationValue(input: []const u8) u32{
   var first_num: ?u8=null;
   var last_num: ?u8=null;
    std.debug.print("\nline={s}\n", .{input});

    std.debug.print("chars:",.{});

    for(input) |c|
    {
    std.debug.print(" {c} ", .{c});

        switch (c) {
            '1'...'9'=> {
                if(first_num == null)
                {
                    first_num = c-'0';
                }
                last_num = c-'0';
            },
            else =>{}
        }

    }
    std.debug.print("\nnum1={d} num2={d}\n", .{first_num.?, last_num.?});
    
    const ouput: u8 = first_num.? * 10 + last_num.?;

    std.debug.print("out={d}\n", .{ouput});

    return ouput;
}

pub fn main() !void {
    const file = try std.fs.Dir.openFile(  std.fs.cwd(),"./calibration_value.txt", .{.mode=.read_only, .lock=.none});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var sum : u32= 0;


    var buf: [100]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {

        // std.debug.print("line={s} Bytes={d} \n", .{line, line.len});

        sum += getCalibrationValue(line);
        std.debug.print("sum={d}\n\n", .{sum});
    }

    std.debug.print("final={d}", .{sum});
}


test "construct" {

        try expect(getCalibrationValue("1abc2") == 12);
        try expect(getCalibrationValue("pqr3stu8vwx") == 38);
        try expect(getCalibrationValue("a1b2c3d4e5f") == 15);
        try expect((getCalibrationValue("treb7uchet") == 77));
}