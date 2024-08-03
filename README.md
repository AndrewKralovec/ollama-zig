# ollama-zig
A simple client library for interacting with the Ollama API.
After reading that [bun](https://bun.sh/) was coded in zig, i wanted to try it out. 
I decided to teach myself by making a library for interacting with the Ollama API.

The client will interact with Ollama server via http, using the [Ollama API](https://github.com/ollama/ollama/blob/main/docs/api.md).

## Usage 

Initialize the client by entering the base url to the Ollama server.
Note, the default url for ollama is "http://127.0.0.1:11434".
```zig
const client = ollama.newOllama("http://127.0.0.1:11434");
```

### Chat

Generate the next message in a chat with a provided model. The method will throw if the Ollama server responds with a bad HTTP status code. 
```zig
const client = ollama.newOllama(allocator, "http://127.0.0.1:11434");
const res = try client.chat(chat_args);
defer res.deinit();
const chat_resp = res.value; // Response object
```

*Note*, streaming is not yet enabled. I still need investigate how to zig can read the streaming endpoint. If stream is set to true, the request will fail.
```zig
const client = ollama.newOllama(allocator, "http://127.0.0.1:11434");
const chat_args = ollama.ChatArgs{
    .model = model,
    .messages = messages,
    .stream = true, // Setting stream to true. 
};
const res = try client.chat(chat_args); // The request will fail. 
```

You can send a chat message with a conversation history. You can use this same approach to start the conversation using multi-shot or chain-of-thought prompting.
```zig
const u_msg_1 = ollama.ChatMessage{ .role = "user", .content = "ping." };
const a_msg_1 = ollama.ChatMessage{ .role = "agent", .content = "It seems like you're trying to test the connection." };
const u_msg_2 = ollama.ChatMessage{ .role = "user", .content = "Correct. Did it work?" };
const chat_args = ollama.ChatArgs{
    .model = model,
    .messages = &[_]ollama.ChatMessage{ u_msg_1, a_msg_1, u_msg_2 },
    .stream = false,
};
const res = try client.chat(chat_args);
defer res.deinit();
```

## Tests
Until i figure out the proper way to mock HTTP clients/requests in zig, the Ollama server needs to be running.

Run tests by using the zig test command.
```sh
zig test test_ollama_zig.zig
```