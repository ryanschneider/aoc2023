const std = @import("std");

pub fn main() !void {
    const path = "day2_1.txt";
    const contents = @embedFile(path);

    const acceptableRed: u8 = 12;
    const acceptableGreen: u8 = 13;
    const acceptableBlue: u8 = 14;
    var partOneAcceptedSums: u32 = 0;
    var partTwoTotalPower: u32 = 0;

    // Game X: R red, G green, B blue;
    var lineIter = std.mem.splitScalar(u8, contents, '\n');
    while (lineIter.next()) |line| {
        if (line.len == 0) break;
        var gs = std.mem.splitScalar(u8, line, ':');
        const name = gs.next().?;
        var nameTokens = std.mem.tokenizeScalar(u8, name, ' ');
        _ = nameTokens.next().?; // chomp "Game"
        const idStr = nameTokens.next().?;
        const id = try std.fmt.parseUnsigned(u8, idStr, 10);

        const games = gs.next().?;
        var gamesIter = std.mem.splitScalar(u8, games, ';');
        var possible = true;
        var maxRed: u8 = 0;
        var maxGreen: u8 = 0;
        var maxBlue: u8 = 0;
        while (gamesIter.next()) |game| {
            var counts = std.mem.splitSequence(u8, game, ", ");
            var red: u8 = 0;
            var green: u8 = 0;
            var blue: u8 = 0;
            while (counts.next()) |entry| {
                // entry = N color
                var tokens = std.mem.tokenizeScalar(u8, entry, ' ');
                const amount = tokens.next().?;
                const colorName = tokens.next().?;
                // std.debug.print("{s} -> {s} {s}", .{ entry, amount, colorName });
                const count = try std.fmt.parseUnsigned(u8, amount, 10);
                if (std.mem.eql(u8, "red", colorName)) {
                    red = count;
                } else if (std.mem.eql(u8, "blue", colorName)) {
                    blue = count;
                } else if (std.mem.eql(u8, "green", colorName)) {
                    green = count;
                } else {
                    unreachable;
                }
            }
            maxRed = @max(red, maxRed);
            maxGreen = @max(green, maxGreen);
            maxBlue = @max(blue, maxBlue);

            if (red > acceptableRed or blue > acceptableBlue or green > acceptableGreen) {
                std.debug.print("Game {} - impossible! red: {} blue: {} green: {}\n", .{ id, red, blue, green });
                possible = false;
            } else {
                std.debug.print("Game {} - possible! {} {} {}\n", .{ id, red, blue, green });
            }
        }
        const power: u32 = @as(u32, maxRed) * @as(u32, maxGreen) * @as(u32, maxBlue);
        partTwoTotalPower += power;

        if (possible) {
            std.debug.print("Game {} - ACCEPTED!\n", .{id});
            partOneAcceptedSums += id;
        }
    } else {
        unreachable;
    }
    std.debug.print("Part One Sum: {}\nPart Two Power: {}\n", .{ partOneAcceptedSums, partTwoTotalPower });
}
