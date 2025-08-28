# Installation Guide for claude-cto via Homebrew

## Prerequisites

- **macOS** 12.0+ or **Linux** with Homebrew installed
- **Python** 3.10+ (Python 3.12 is automatically installed by the formula)
- **Anthropic API Key** or Claude CLI authentication

## Quick Installation

```bash
# Add the tap
brew tap yigitkonur/claude-cto

# Install claude-cto
brew install claude-cto

# Start the service (optional - for background daemon)
brew services start yigitkonur/claude-cto/claude-cto
```

## Detailed Installation Steps

### 1. Add the Homebrew Tap

```bash
brew tap yigitkonur/claude-cto
```

This adds the custom repository containing the claude-cto formula.

### 2. Install the Formula

```bash
brew install claude-cto
```

This will:
- Install Python 3.12 if not present
- Create a virtual environment
- Install claude-cto with all dependencies
- Set up required directories
- Configure the CLI commands

### 3. Configure Authentication

#### Option A: Using Anthropic API Key
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

Add this to your shell profile (`~/.zshrc` or `~/.bashrc`) to persist.

#### Option B: Using Claude CLI Authentication
```bash
claude auth login
```

### 4. Verify Installation

```bash
# Check CLI is working
claude-cto --help

# Test server startup
claude-cto server start
```

## Running as a Service

### Start Service
```bash
brew services start yigitkonur/claude-cto/claude-cto
```

### Stop Service
```bash
brew services stop yigitkonur/claude-cto/claude-cto
```

### Check Service Status
```bash
brew services list | grep claude-cto
```

### View Logs
```bash
tail -f /opt/homebrew/var/log/claude-cto.log
tail -f /opt/homebrew/var/log/claude-cto-error.log
```

## MCP Integration

To integrate with Claude Desktop, add to your MCP configuration:

```bash
claude mcp add claude-cto -s user -- python -m claude_cto.mcp.factory
```

This enables claude-cto as a Model Context Protocol server for Claude Desktop.

## Directory Structure

After installation, claude-cto uses these directories:

- **Configuration**: `/opt/homebrew/var/claude-cto/`
- **Database**: `/opt/homebrew/var/claude-cto/tasks.db`
- **Logs**: `/opt/homebrew/var/log/`
- **Binaries**: `/opt/homebrew/bin/claude-cto`

## Upgrading

```bash
# Update tap
brew update

# Upgrade claude-cto
brew upgrade claude-cto

# Restart service if running
brew services restart yigitkonur/claude-cto/claude-cto
```

## Uninstallation

```bash
# Stop service if running
brew services stop yigitkonur/claude-cto/claude-cto

# Uninstall formula
brew uninstall claude-cto

# Remove tap (optional)
brew untap yigitkonur/claude-cto

# Clean up data (optional)
rm -rf /opt/homebrew/var/claude-cto
rm -f /opt/homebrew/var/log/claude-cto*.log
```

## Troubleshooting

### Service won't start

1. Check if port 8000 is already in use:
```bash
lsof -i :8000
```

2. Check service logs:
```bash
tail -f /opt/homebrew/var/log/claude-cto-error.log
```

3. Try starting manually:
```bash
claude-cto server start --port 8001
```

### Command not found

Ensure Homebrew's bin directory is in your PATH:
```bash
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Python module errors

Reinstall with verbose output:
```bash
brew reinstall claude-cto --verbose
```

### Database locked errors

Reset the database:
```bash
rm /opt/homebrew/var/claude-cto/tasks.db
brew services restart yigitkonur/claude-cto/claude-cto
```

### API authentication issues

1. Verify API key is set:
```bash
echo $ANTHROPIC_API_KEY
```

2. Try Claude CLI auth:
```bash
claude auth login
```

## Building from Source

If you need to modify the formula:

```bash
# Clone the tap
git clone https://github.com/yigitkonur/homebrew-claude-cto.git
cd homebrew-claude-cto

# Edit formula
vim Formula/claude-cto.rb

# Test locally
brew install --build-from-source ./Formula/claude-cto.rb
```

## Creating Bottles

For maintainers who need to build bottles:

```bash
# Install with bottle support
brew install --build-bottle claude-cto

# Create bottle
brew bottle --json --root-url="https://github.com/yigitkonur/homebrew-claude-cto/releases/download/v0.5.1" claude-cto

# Upload the generated .tar.gz file to GitHub releases
```

## Support

- **Documentation**: https://github.com/yigitkonur/claude-cto
- **Issues**: https://github.com/yigitkonur/homebrew-claude-cto/issues
- **PyPI Package**: https://pypi.org/project/claude-cto/

## License

MIT License - See [LICENSE](https://github.com/yigitkonur/claude-cto/blob/main/LICENSE) for details.