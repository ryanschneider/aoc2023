const std = @import("std");

pub fn main() !void {
    const path = "day1_1.txt";
    const _contents = @embedFile(path);
    var contents: [_contents.len:0]u8 = undefined;
    @memcpy(&contents, _contents);
    for (contents, 0..) |_, i| {
        const size = @min(5, contents.len - i);
        const word = contents[i..(i + size)];
        // zero => 0ero
        // one => 1ne
        // two => 2wo
        // three => 3hree
        // four => 4our
        // five => 5ive
        // six => 6ix
        // seven => 7even
        // eight => 8ight
        // nine => 9ine
        if (std.mem.startsWith(u8, word, "zero")) {
            contents[i] = '0';
        } else if (std.mem.startsWith(u8, word, "one")) {
            contents[i] = '1';
        } else if (std.mem.startsWith(u8, word, "two")) {
            contents[i] = '2';
        } else if (std.mem.startsWith(u8, word, "three")) {
            contents[i] = '3';
        } else if (std.mem.startsWith(u8, word, "four")) {
            contents[i] = '4';
        } else if (std.mem.startsWith(u8, word, "five")) {
            contents[i] = '5';
        } else if (std.mem.startsWith(u8, word, "six")) {
            contents[i] = '6';
        } else if (std.mem.startsWith(u8, word, "seven")) {
            contents[i] = '7';
        } else if (std.mem.startsWith(u8, word, "eight")) {
            contents[i] = '8';
        } else if (std.mem.startsWith(u8, word, "nine")) {
            contents[i] = '9';
        }
        // std.debug.print("{s} {} {} {}\n", .{ word, i, contents.len, size });
    }
    //std.debug.print("---\n{s}\n---\n", .{contents});

    var digits: [2]u8 = undefined; // [lo, hi]
    var sum: u32 = 0;
    var count: u16 = 0;

    for (contents) |ch| {
        if (ch == '\n') {
            if (count == 1) {
                digits[1] = digits[0];
            }
            var value = (digits[0] - '0') * 10 + (digits[1] - '0');
            // std.debug.print("{} {} -> {} ({})\n", .{ digits[0] - '0', digits[1] - '0', value, count });
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
