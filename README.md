# Homebrew Tap for claude-cto

## Installation

```bash
brew tap yigitkonur/claude-cto
brew install claude-cto
```

## What is claude-cto?

🗿 Your AI coding agents' CTO that gets stuff done 10x faster. Fire-and-forget task execution system for Claude Code SDK with parallel execution, smart dependencies, and workflow automation.

## Features

- 🚀 **Parallel Execution**: Run multiple Claude AI agents simultaneously
- 🔗 **Smart Dependencies**: Automatically handles task dependencies  
- 🧠 **Model Selection**: Use Opus/Sonnet/Haiku per task to optimize cost
- 📊 **Resource Monitoring**: Tracks CPU/memory to prevent system overload
- 💾 **Crash Recovery**: Persists everything to disk for resumability
- 🛡️ **Circuit Breaker**: Stops retrying broken components intelligently

## Quick Start

### Basic Usage

```bash
# Install via Homebrew
brew install yigitkonur/claude-cto/claude-cto

# Start the server
claude-cto server start

# Run as a service (background daemon)
brew services start yigitkonur/claude-cto/claude-cto
```

### CLI Commands

```bash
# Fire off a single task
claude-cto run "implement user authentication system"

# Submit an orchestration from JSON
claude-cto orchestrate workflow.json

# Check task status
claude-cto status 1

# List all tasks
claude-cto list
```

## MCP Integration

claude-cto includes Model Context Protocol (MCP) support for Claude Desktop and VSCode:

```bash
# The MCP server is included and can be configured in Claude Desktop
# See documentation for MCP setup instructions
```

## Configuration

Configuration directory: `$(brew --prefix)/var/claude-cto`
Logs directory: `$(brew --prefix)/var/log/claude-cto`

## Requirements

- Python 3.10+
- Node.js 16+ (for Claude CLI)
- Anthropic API key (optional - uses Claude subscription by default)

## Documentation

- [Main Repository](https://github.com/yigitkonur/claude-cto)
- [PyPI Package](https://pypi.org/project/claude-cto/)
- [MCP Documentation](https://github.com/yigitkonur/claude-cto/blob/main/MCP_README.md)

## Troubleshooting

### Service won't start

```bash
# Check service status
brew services list

# View logs
tail -f $(brew --prefix)/var/log/claude-cto.log

# Restart service
brew services restart claude-cto
```

### Port 8000 already in use

The service will automatically find an available port. Check logs for the actual port being used.

### Database issues

```bash
# Reset database (warning: clears all tasks)
rm $(brew --prefix)/var/claude-cto/tasks.db
brew services restart claude-cto
```

## License

MIT License - See [LICENSE](https://github.com/yigitkonur/claude-cto/blob/main/LICENSE) for details

## Author

Yigit Konur - [@yigitkonur](https://github.com/yigitkonur)