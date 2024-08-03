# ollama-zig
A simple client library for interacting with the Ollama API.
After reading that [bun](https://bun.sh/) was coded in zig, i wanted to try it out. 
I decided to teach myself by making a library for interacting with the Ollama API.

The client will interact with Ollama server via http, using the [Ollama API](https://github.com/ollama/ollama/blob/main/docs/api.md).

## Usage 

Initialize the client by entering the base url to the Ollama server.
Note, the default url for ollama is "http://127.0.0.1:11434".
```zig
const client = ollama.NewOllama("http://127.0.0.1:11434");
```

## Tests
Until i figure out the proper way to mock HTTP clients/requests in zig, the Ollama server needs to be running.

Run tests by using the zig test command.
```sh
zig test tes_ollama_zig.zig
```