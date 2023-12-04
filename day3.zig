const std = @import("std");
const assert = @import("std").debug.assert;

pub fn main() !void {
    const schematic = comptime parse: {
        const path = "day3.txt";
        const raw = @embedFile(path);
        const width = std.mem.indexOfScalar(u8, raw, '\n').? + 1;
        assert(width >= 1);
        const height = raw.len / width;
        const s: *const [height][width]u8 = @ptrCast(raw);
        break :parse s;
    };
    const height = schematic.len;
    const width = schematic[0].len;
    // std.debug.print("{s} {c} {c}\n", .{ schematic[2], schematic[2][2], schematic[2][3] });
    const Mask = enum { period, digit, symbol };
    const mask = comptime parse: {
        var mask: [schematic.len][schematic[0].len]Mask = undefined;
        @setEvalBranchQuota(schematic.len * schematic[0].len * 4);
        for (schematic, 0..) |row, y| {
            for (row, 0..) |value, x| {
                mask[y][x] = switch (value) {
                    '.' => .period,
                    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' => .digit,
                    else => .symbol,
                };
            }
        }
        break :parse &mask;
    };
    // std.debug.print("{any} {} {}\n", .{ mask, mask[2][0], mask[2][1] });
    // . . 1 2 3 $ => . . D D D S
    // - find first digit -> i
    // - find last digit => j
    // - find all surrounding masks
    // - if any are symbol, accept
    // - value = parseUnsigned(row[i..j])
    var x: u32 = 0;
    for (schematic, 0..) |row, y| {
        x = 0;
        std.debug.print("row {}: ", .{y});
        while (x < width) {
            if (mask[y][x] == .digit) {
                const first_digit_idx = x;
                var last_digit_idx = x + 1;
                while (last_digit_idx < width) : (last_digit_idx += 1) {
                    if (mask[y][last_digit_idx] != .digit) {
                        break;
                    }
                }
                x = last_digit_idx;
                var adjacent = false;
                const left = if (first_digit_idx == 0) 0 else first_digit_idx - 1;
                const right = if (last_digit_idx < width) last_digit_idx + 1 else width;
                if (y > 0) {
                    const above = mask[y - 1][left..right];
                    for (above) |a| {
                        if (a == .symbol) {
                            adjacent = true;
                            break;
                        }
                    }
                }
                if (!adjacent and (mask[y][left] == .symbol or mask[y][right] == .symbol)) {
                    adjacent = true;
                }
                if (!adjacent and y < height - 1) {
                    const below = mask[y + 1][left..right];
                    for (below) |b| {
                        if (b == .symbol) {
                            adjacent = true;
                            break;
                        }
                    }
                }
                std.debug.print("{s} {}\t", .{ row[first_digit_idx..last_digit_idx], adjacent });
            } else {
                x += 1;
            }
        }
        std.debug.print("\n", .{});
    }
}
