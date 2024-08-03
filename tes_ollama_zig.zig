const ollama = @import("./ollama_zig.zig");
const std = @import("std");
const expect = std.testing.expect;

test "should return base_url from self" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const expected_url: []const u8 = "http://127.0.0.1:11434";
    const client = ollama.NewOllama(allocator, expected_url);
    try expect(std.mem.eql(u8, client.base_url, expected_url));
}

test "should send chat messages to Ollama server" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const role = "user";
    const content = "ping";
    const model = "llama3.1";

    const message = ollama.ChatMessageArgs{
        .role = role,
        .content = content,
    };
    const chat_args = ollama.ChatArgs{
        .model = model,
        .messages = &[_]ollama.ChatMessageArgs{message},
        .stream = false,
    };

    const client = ollama.NewOllama(allocator, "http://127.0.0.1:11434");

    const resp = try client.chat(chat_args);
    defer resp.deinit();

    std.debug.print("Body:\n{s}\n", .{resp.value.message.content});
}
