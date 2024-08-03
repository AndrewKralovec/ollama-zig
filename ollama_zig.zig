// The ollama client type.
const Ollama = struct {
    // Ollamaa server base url.
    base_url: []const u8,
};

// Create a new ollama client.
pub fn NewOllama(url: []const u8) Ollama {
    return Ollama{ .base_url = url };
}
