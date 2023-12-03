const std = @import("std");

pub fn main() !void {
    // cheat: embed the file at compile time
    const path = "day1_1.txt";
    const contents = @embedFile(path);

    var digits: [2]u8 = undefined; // [lo, hi]
    var sum: u32 = 0;
    var count: u16 = 0;

    for (contents) |ch| {
        if (ch == '\n') {
            if (count == 1) {
                digits[1] = digits[0];
            }
            var value = (digits[0] - '0') * 10 + (digits[1] - '0');
            std.debug.print("{} {} -> {} ({})\n", .{ digits[0] - '0', digits[1] - '0', value, count });
            sum += value;
            count = 0;
        }
        if (ch >= '0' and ch <= '9') {
            // digit
            if (count == 0) {
                digits[0] = ch;
                count = 1;
            } else {
                digits[1] = ch;
                count = 2;
            }
        }
    }

    std.debug.print("{}", .{sum});
}
