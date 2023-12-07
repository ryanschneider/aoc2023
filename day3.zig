const std = @import("std");
const assert = @import("std").debug.assert;

const Found = packed struct {
    above: bool,
    below: bool,
    left: bool,
    right: bool,

    pub fn format(self: Found, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;

        const a: u8 = if (self.above) 'A' else '.';
        const b: u8 = if (self.below) 'B' else '.';
        const l: u8 = if (self.left) 'L' else '.';
        const r: u8 = if (self.right) 'R' else '.';

        try writer.print("Found< {c}{c}{c}{c} >", .{
            a, b, l, r,
        });
    }
};

const Mask = union(enum) {
    period,
    digit: struct { id: u16, value: u16 },
    symbol: u8,
    newline,
};

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
    const mask = comptime parse: {
        var mask: [schematic.len][schematic[0].len]Mask = undefined;
        @setEvalBranchQuota(schematic.len * schematic[0].len * 4);
        for (schematic, 0..) |row, y| {
            for (row, 0..) |value, x| {
                mask[y][x] = switch (value) {
                    '.' => .period,
                    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' => Mask{ .digit = .{ .id = 0, .value = 0 } },
                    '\n' => .newline,
                    else => Mask{ .symbol = value },
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
    {
        var x: u32 = 0;
        var part_one_sum: u32 = 0;
        var number_id: u16 = 0;

        for (schematic, 0..) |row, y| {
            x = 0;
            std.debug.print("row {}: ", .{y});
            while (x < width) {
                if (mask[y][x] == .digit) {
                    number_id += 1;
                    const first_digit_idx = x;
                    var last_digit_idx = x + 1;
                    while (last_digit_idx < width) : (last_digit_idx += 1) {
                        if (mask[y][last_digit_idx] != .digit) {
                            last_digit_idx -= 1;
                            break;
                        }
                    }

                    const number = row[first_digit_idx .. last_digit_idx + 1];
                    const value = try std.fmt.parseUnsigned(u16, number, 10);
                    for (mask[y][first_digit_idx .. last_digit_idx + 1]) |*d| {
                        assert(d.* == .digit);
                        d.* = Mask{ .digit = .{ .id = number_id, .value = value } };
                    }
                    var adjacent = Found{ .above = false, .below = false, .left = false, .right = false };
                    const left = if (first_digit_idx == 0) 0 else first_digit_idx - 1;
                    const right = if (last_digit_idx < width) last_digit_idx + 1 else width;
                    if (y > 0) {
                        const above = mask[y - 1][left .. right + 1];
                        for (above) |a| {
                            if (a == .symbol) {
                                adjacent.above = true;
                                break;
                            }
                        }
                    }
                    if (mask[y][left] == .symbol) {
                        adjacent.left = true;
                    }
                    if (mask[y][right] == .symbol) {
                        adjacent.right = true;
                    }
                    if (y < height - 1) {
                        const below = mask[y + 1][left .. right + 1];
                        for (below) |b| {
                            if (b == .symbol) {
                                adjacent.below = true;
                                break;
                            }
                        }
                    }
                    std.debug.print("{s}(id: {} {})\t", .{ number, mask[y][x].digit.id, adjacent });
                    if (adjacent.above or adjacent.below or adjacent.left or adjacent.right) {
                        // std.debug.print("accepted: {s} {}\t", .{ number, value });
                        part_one_sum += value;
                    } else {
                        // std.debug.print("rejected {s} ({s} row[{}][{}]) at ({}, {}, l: {} {} r: {} {})\t", .{ row[left .. right + 1], number, first_digit_idx, last_digit_idx, x, y, left, mask[y][left], right, mask[y][right] });
                        // std.debug.print("rejected {s}\t", .{row[left .. right + 1]});
                    }
                    x = last_digit_idx + 1;
                } else {
                    x += 1;
                }
            }
            std.debug.print("\nsum (part one): {}\n", .{part_one_sum});
        }
    }

    if (true) {
        var part_two_gear_ratios_sum: u32 = 0;
        for (schematic, 0..) |row, y| {
            for (row, 0..) |c, x| {
                if (c == '*') {
                    assert(mask[y][x].symbol == c);
                } else {
                    continue;
                }

                // find all the characters "around" mask[y][x]
                const check_left: ?usize = if (x > 0) x - 1 else null;
                const check_right: ?usize = if (x < width) x + 1 else null;
                const check_above: ?usize = if (y > 0) y - 1 else null;
                const check_below: ?usize = if (y < height) y + 1 else null;

                var checker = GearChecker.init();
                // (A,L) (A, ) (A,R)
                // ( ,L) (   ) ( ,R)
                // (B,L) (B, ) (B,R)
                if (check_above) |above| {
                    if (check_left) |left| {
                        try checker.check(mask[above][left]);
                    }
                    if (true) {
                        try checker.check(mask[above][x]);
                    }
                    if (check_right) |right| {
                        try checker.check(mask[above][right]);
                    }
                }
                if (true) {
                    if (check_left) |left| {
                        try checker.check(mask[y][left]);
                    }
                    // dont check self..
                    if (check_right) |right| {
                        try checker.check(mask[y][right]);
                    }
                }
                if (check_below) |below| {
                    if (check_left) |left| {
                        try checker.check(mask[below][left]);
                    }
                    if (true) {
                        try checker.check(mask[below][x]);
                    }
                    if (check_right) |right| {
                        try checker.check(mask[below][right]);
                    }
                }
                std.debug.print("Potential gear at {} {} has {} touches\n", .{ x, y, checker.count });
                if (checker.result()) |ratio| {
                    part_two_gear_ratios_sum += ratio;
                    std.debug.print("Part two sum: {}\n", .{part_two_gear_ratios_sum});
                }
            }
        }
    }
}

const GearChecker = struct {
    const Self = @This();

    count: usize,
    adjacents: [9]struct {
        id: u16,
        value: u16,
    },

    fn init() Self {
        return Self{
            .count = 0,
            .adjacents = undefined,
        };
    }

    fn check(self: *Self, mask: Mask) !void {
        switch (mask) {
            .digit => |d| {
                const id = d.id;
                if (self.count > 9) {
                    return error.OutOfMemory;
                }
                for (self.adjacents[0..self.count]) |a| {
                    if (a.id == id) {
                        return;
                    }
                }
                const value = d.value;
                self.adjacents[self.count] = .{
                    .id = id,
                    .value = value,
                };
                self.count += 1;
            },
            else => return,
        }
    }

    fn result(self: *Self) ?u32 {
        if (self.count == 2) {
            const r0: u32 = self.adjacents[0].value;
            const r1: u32 = self.adjacents[1].value;
            const r: u32 = r0 * r1;
            return r;
        } else {
            return null;
        }
    }
};

test "widening" {
    const a: u16 = std.math.maxInt(u16);
    const b: u16 = std.math.maxInt(u16);

    const c: u32 = a + b;
    try std.testing.expect(c == 65536 * 65536);
}
