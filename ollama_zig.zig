const std = @import("std");
const http = std.http;
const json = std.json;

// Create a new ollama client.
pub fn newOllama(allocator: std.mem.Allocator, url: []const u8) Ollama {
    return Ollama{ .allocator = allocator, .base_url = url };
}

// The ollama client type.
pub const Ollama = struct {
    // Client allocator,
    allocator: std.mem.Allocator,
    // Ollamaa server base url.
    base_url: []const u8,
    // Generate the next message in a chat with a provided model.
    // The final response object will include statistics and additional data from the request.
    // NOTE: Streaming is not yet setup. If stream is set to true, the request will fail.
    // Once enabled, chat is a streaming endpoint, so there will be a series of responses.
    // Streaming can be disabled using "stream": false.
    pub fn chat(self: Ollama, args: ChatArgs) !json.Parsed(ChatResponse) {
        const allocator = self.allocator;

        // TODO: Find out how we could optimze this.
        // Could we use comptime for this? If `base_url` was set via ENV, could it still find out the size at comptime. Need to read more about comptime.
        const url = try concatAlloc(allocator, self.base_url, "/api/chat");
        defer allocator.free(url);

        const uri = try std.Uri.parse(url);
        const body = try post(allocator, uri, args);
        defer allocator.free(body);

        // NOTE: Returing `json.Parsed(ChatResponse)` instead of `ChatResponse` for now.
        // While i feel like `ChatResponse` is a more proper return type.
        // the `deinit` seems less pronte to leak due to forgetting to free one of the fields.
        // I don't think that the std has a generic deep copy function in it. Need to revisit this.
        const parsed = try json.parseFromSlice(ChatResponse, allocator, body, .{ .allocate = .alloc_always, .ignore_unknown_fields = true });
        return parsed;
    }
};

// Chat arguments type.
pub const ChatArgs = struct {
    // REQUIRED: the model name.
    model: []const u8,
    // The messages of the chat, this can be used to keep a chat memory.
    messages: []const ChatMessage,
    // NOTE: Streaming is not yet implemented.
    // The false the response will be returned as a single response object, rather than a stream of objects.
    stream: bool,
};
// Chat message type.
pub const ChatMessage = struct {
    // The role of the message, either system, user, assistant, or tool.
    role: []const u8,
    // The content of the message.
    content: []const u8,
};
// Chat response type.
pub const ChatResponse = struct {
    // REQUIRED: the model name.
    model: []const u8,
    // The messages of the chat, this can be used to keep a chat memory.
    message: ChatMessage,
    // Time created.
    created_at: []const u8,
    // Reason for stream end.
    done_reason: []const u8,
    // Stream is done.
    done: bool,
    // Time spent generating the response.
    total_duration: usize,
    // Time spent in nanoseconds loading the model.
    load_duration: usize,
    // Number of tokens in the prompt.
    prompt_eval_count: usize,
    //  Time spent in nanoseconds evaluating the prompt.
    prompt_eval_duration: usize,
    // Number of tokens in the response.
    eval_count: usize,
    // Time in nanoseconds spent generating the response.
    eval_duration: usize,
};

// Concatenate two strings. Returns an allocated string slice.
fn concatAlloc(allocator: std.mem.Allocator, l: []const u8, r: []const u8) ![]u8 {
    const size = l.len + r.len;
    var buffer = try allocator.alloc(u8, size);
    var index: usize = 0;
    for (l) |c| {
        buffer[index] = c;
        index += 1;
    }
    for (r) |c| {
        buffer[index] = c;
        index += 1;
    }
    return buffer;
}

// Make a HTTP post call.
// The function will stringify the input and return a string slice.
fn post(allocator: std.mem.Allocator, uri: std.Uri, input: anytype) ![]u8 {
    var client = http.Client{
        .allocator = allocator,
    };
    defer client.deinit();

    const payload = try json.stringifyAlloc(allocator, input, .{ .whitespace = .indent_2 });
    defer allocator.free(payload);

    var buf: [1024]u8 = undefined;
    var req = try client.open(.POST, uri, .{
        .server_header_buffer = &buf,
        .headers = .{
            .content_type = .{ .override = "application/json" },
        },
    });
    defer req.deinit();

    req.transfer_encoding = .{ .content_length = payload.len };
    try req.send();
    var wtr = req.writer();
    try wtr.writeAll(payload);
    try req.finish();
    try req.wait();
    try std.testing.expectEqual(req.response.status, .ok);

    // TODO: Find out best stragety for dealing with max alloc size.
    var rdr = req.reader();
    const body = try rdr.readAllAlloc(allocator, 1024 * 1024 * 4);
    return body;
}
