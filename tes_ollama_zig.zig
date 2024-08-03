const ollama = @import("./ollama_zig.zig");
const std = @import("std");
const expect = std.testing.expect;

test "should return base_url from self" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const expected_url: []const u8 = "http://127.0.0.1:11434";
    const client = ollama.newOllama(allocator, expected_url);
    try expect(std.mem.eql(u8, client.base_url, expected_url));
}

test "should send chat messages to Ollama server" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const role = "user";
    const content = "ping";
    const model = "llama3.1";

    const message = ollama.ChatMessage{
        .role = role,
        .content = content,
    };
    const chat_args = ollama.ChatArgs{
        .model = model,
        .messages = &[_]ollama.ChatMessage{message},
        .stream = false,
    };

    const client = ollama.newOllama(allocator, "http://127.0.0.1:11434");
    const resp = try client.chat(chat_args);
    defer resp.deinit();

    const chat_resp = resp.value;
    try expect(chat_resp.message.content.len > 0);
}

test "should send chat messages history to Ollama server" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const model = "llama3.1";
    const u_msg_1 = ollama.ChatMessage{
        .role = "user",
        .content = "ping",
    };
    const a_msg_1 = ollama.ChatMessage{
        .role = "agent",
        .content = "It seems like you're trying to test the connection.",
    };
    const u_msg_2 = ollama.ChatMessage{
        .role = "user",
        .content = "Correct. Did it work?",
    };
    const chat_args = ollama.ChatArgs{
        .model = model,
        .messages = &[_]ollama.ChatMessage{ u_msg_1, a_msg_1, u_msg_2 },
        .stream = false,
    };

    const client = ollama.newOllama(allocator, "http://127.0.0.1:11434");
    const resp = try client.chat(chat_args);
    defer resp.deinit();

    const chat_resp = resp.value;
    try expect(chat_resp.message.content.len > 0);
}
