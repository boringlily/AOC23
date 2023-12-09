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

const Hand = struct {
    cards: [5]u8,
    card_values: [5]u8,
    bet: u32,
    type: HandType,
};

fn readHand(line: []const u8) Hand {
    const cards: [5]u8 = line[0..5].*;
    const bet: []const u8 = line[6..];

    var hand = Hand{
        .cards = cards,
        .card_values = getCardsArray(cards),
        .bet = getBetValue(bet),
        .type = getHandType(cards),
    };

    return hand;
}

fn getBetValue(str: []const u8) u32 {
    var bet: u32 = 0;

    for (str) |c| {
        switch (c) {
            '0'...'9' => {
                bet = (bet * 10) + (c - '0');
            },
            else => {},
        }
    }
    return bet;
}

fn getHandType(cards: [5]u8) HandType {
    var sorted: [5]u8 = cards;

    for (cards, 0..) |num, index| {
        sorted[index] = cardValue(num);
    }
    std.sort.insertion(u8, &sorted, {}, std.sort.asc(u8));

    var count: [5]u8 = undefined;
    @memset(&count, 0);
    count[0] = 1;
    var jcount: u8 = 0;
    var i: u8 = 0;
    for (sorted, 0..) |num, index| {
        if (index == 4) {
            break;
        }
        if (num == 1) {
            jcount += 1;
        } else if (num == sorted[index + 1]) {
            count[i] += 1;
        } else {
            if (count[i] == 0) {
                count[i] += 1;
            }
            i += 1;
            count[i] += 1;
        }
    }
    std.sort.insertion(u8, &count, {}, std.sort.desc(u8));

    count[0] += jcount;

    // std.debug.print("cards:{s} count:{any} \n ", .{ cards, count });
    if (std.meta.eql(count, [5]u8{ 5, 0, 0, 0, 0 })) {
        return HandType.five_kind;
    } else if (std.meta.eql(count, [5]u8{ 4, 1, 0, 0, 0 })) {
        return HandType.four_kind;
    } else if (std.meta.eql(count, [5]u8{ 3, 2, 0, 0, 0 })) {
        return HandType.full_house;
    } else if (std.meta.eql(count, [5]u8{ 3, 1, 1, 0, 0 })) {
        return HandType.three_kind;
    } else if (std.meta.eql(count, [5]u8{ 2, 2, 1, 0, 0 })) {
        return HandType.two_pair;
    } else if (std.meta.eql(count, [5]u8{ 2, 1, 1, 1, 0 })) {
        return HandType.one_pair;
    } else {
        return HandType.high_card;
    }
}

fn getCardsArray(cards: [5]u8) [5]u8 {
    var out: [5]u8 = undefined;
    for (cards, 0..) |c, i| {
        out[i] = cardValue(c);
    }
    return out;
}

fn cardValue(card: u8) u8 {
    switch (card) {
        'J' => return 1,
        '2'...'9' => {
            return (card - '0');
        },
        'T' => return 10,
        'Q' => return 11,
        'K' => return 12,
        'A' => return 13,
        else => {
            unreachable;
        },
    }
}

fn cmpHandByScore(context: void, a: Hand, b: Hand) bool {
    _ = context;
    const at: u32 = @intFromEnum(a.type);
    const bt: u32 = @intFromEnum(b.type);

    if (at == bt) {
        for (0..5) |i| {
            if (a.card_values[i] == b.card_values[i]) {
                continue;
            } else if (a.card_values[i] < b.card_values[i]) {
                return true;
            } else if (a.card_values[i] > b.card_values[i]) {
                return false;
            } else {}
        }
    }
    if (at < bt) {
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

    var buf: [20]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try hand_buffer.append(readHand(line));
    }
    var x = try hand_buffer.toOwnedSlice();

    std.sort.insertion(Hand, x, {}, cmpHandByScore);

    for (x, 0..) |item, index| {
        std.debug.print("\nHand: {s} Cards: {s}  Bet: {d}, card values: {any}, i:{d}\n", .{ @tagName(item.type), item.cards, item.bet, item.card_values, index + 1 });
        winnings += (item.bet *% (index + 1));
    }

    std.debug.print("winnings: {d}\n", .{winnings});
    return winnings;
}

pub fn main() !void {
    const winnings = try getWinnings(false);
    _ = winnings;
}

test "test winnings" {
    try expect(try getWinnings(true) == 5905);
}
