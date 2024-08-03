const ollama = @import("./ollama_zig.zig");
const std = @import("std");
const expect = std.testing.expect;

test "should return base_url from self" {
    const expected_url: []const u8 = "http://127.0.0.1:11434";
    const client = ollama.NewOllama(expected_url);
    try expect(std.mem.eql(u8, client.base_url, expected_url));
}
