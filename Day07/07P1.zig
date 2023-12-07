const std = @import("std");
const expect = std.testing.expect;

const HandType = enum(u32) {
    high_card = 1,
    one_pair,
    two_pair,
    three_kind,
    full_house,
    four_kind,
    five_kind,
};

const Hand = struct { cards: [5]u8, value: u32, bet: u32, type: HandType, score: u32 };

fn readHand(line: []const u8) Hand {
    const cards: [5]u8 = line[0..5].*;

    var hand = Hand{
        .cards = cards,
        .value = getHandValue(cards),
        .bet = 0,
        .type = HandType.one_pair,
        .score = 0,
    };

    hand.score = hand.value * @as(u32, @intFromEnum(hand.type));
    std.debug.print("hand {any}\n", .{hand});
    return hand;
}

fn getHandValue(cards: [5]u8) u32 {
    var sum: u32 = 0;
    for (cards) |c| {
        sum += cardValue(c);
    }
    return sum;
}

fn cardValue(card: u8) u8 {
    switch (card) {
        '2'...'9' => {
            return (card - '0');
        },
        'T' => return 10,
        'J' => return 11,
        'Q' => return 12,
        'K' => return 13,
        'A' => return 14,
        else => {
            unreachable;
        },
    }
}

fn cmpHandByScore(context: void, a: Hand, b: Hand) bool {
    _ = context;
    if (a.score > b.score) {
        return true;
    } else {
        return false;
    }
}

fn getWinnings(readDemo: bool) !u64 {
    const file = try std.fs.Dir.openFile(std.fs.cwd(), (if (readDemo) "./demo.txt" else "./input.txt"), .{ .mode = .read_only, .lock = .none });
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var winnings: u64 = 0;

    const allocator = std.heap.page_allocator;

    var hand_buffer = std.ArrayList(Hand).init(allocator);
    defer hand_buffer.deinit();

    var buf: [100]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try hand_buffer.append(readHand(line));
    }
    var x = try hand_buffer.toOwnedSlice();

    std.sort.insertion(Hand, x, {}, cmpHandByScore);

    for (x, 0..) |item, index| {
        winnings += (item.bet * (index + 1));
    }

    std.debug.print("winnings: {d}\n", .{winnings});
    return winnings;
}

pub fn main() !void {
    const winnings = getWinnings(false);
    _ = winnings;
}

test "test winnings" {
    try expect(try getWinnings(true) == 6440);
}
