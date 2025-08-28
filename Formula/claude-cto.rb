class ClaudeCto < Formula
  include Language::Python::Virtualenv

  desc "Fire-and-forget task execution system for Claude Code SDK"
  homepage "https://github.com/yigitkonur/claude-cto"
  url "https://files.pythonhosted.org/packages/d4/4f/a5b3c268eb03f1c623e806bfb0c411563a13b32129c31603357724027d57/claude_cto-0.8.3.tar.gz"
  sha256 "cbf23c341f12c240712cb23768db625878e514b1f451b32e1c0acc69d9f5b9d8"
  license "MIT"
  head "https://github.com/yigitkonur/claude-cto.git", branch: "main"

  depends_on "python@3.12"
  depends_on "node" => :recommended  # For Claude CLI integration

  def install
    # Create virtualenv
    venv = virtualenv_create(libexec, "python3.12")
    
    # Use system to ensure pip is available in the venv
    system "python3.12", "-m", "venv", "--system-site-packages", libexec
    system libexec/"bin/python", "-m", "ensurepip", "--upgrade"
    
    # Upgrade pip and install the package with all extras
    system libexec/"bin/python", "-m", "pip", "install", "--upgrade", "pip"
    # Install psutil explicitly first (critical dependency that may be missing)
    system libexec/"bin/python", "-m", "pip", "install", "psutil>=5.9.0"
    # Install the package with server and MCP extras for full functionality
    system libexec/"bin/python", "-m", "pip", "install", "claude-cto[server,mcp]==0.8.3"
    
    # Create intelligent wrapper script that auto-configures MCP on first run
    (bin/"claude-cto").write <<~EOS
      #!/bin/bash
      
      # Auto-configure MCP server on first run if Claude CLI is available
      if command -v claude >/dev/null 2>&1; then
        # Check if MCP server is already configured
        if ! claude mcp list 2>/dev/null | grep -q "claude-cto"; then
          echo "🗿 Setting up claude-cto MCP server for Claude Code..."
          claude mcp add claude-cto -s user -- #{libexec}/bin/python -m claude_cto.mcp.factory 2>/dev/null
          if [ $? -eq 0 ]; then
            echo "✓ claude-cto is now available in Claude Code!"
          fi
        fi
      fi
      
      # Execute the actual command
      exec #{libexec}/bin/claude-cto "$@"
    EOS
    
    # Make the wrapper executable
    chmod 0755, bin/"claude-cto"
    
    # Standard symlink for MCP binary
    bin.install_symlink libexec/"bin/claude-cto-mcp"

    # Generate shell completions (simplified without the deprecated parameter)
    # Note: claude-cto doesn't have built-in completion commands yet

    # Create directories for data and logs
    (var/"claude-cto").mkpath
    (var/"log").mkpath
  end

  def post_install
    # Ensure directories exist with correct permissions
    (var/"claude-cto").mkpath
    (var/"log").mkpath
    
    # The MCP configuration is handled by the wrapper script on first run
    ohai "claude-cto will auto-configure MCP integration on first use (if Claude CLI is available)"
  end

  service do
    run [opt_bin/"claude-cto", "server", "start", "--host", "127.0.0.1", "--port", "8000"]
    keep_alive true
    log_path var/"log/claude-cto.log"
    error_log_path var/"log/claude-cto-error.log"
    environment_variables PATH: std_service_path_env,
                         CLAUDE_CTO_DB: var/"claude-cto/tasks.db",
                         CLAUDE_CTO_LOG_DIR: var/"log/claude-cto"
    working_dir var/"claude-cto"
  end

  test do
    # Test version output
    assert_match "0.8", shell_output("#{bin}/claude-cto --version 2>&1", 0)

    # Test help output
    assert_match "Fire-and-forget task execution", shell_output("#{bin}/claude-cto --help 2>&1", 0)

    # Test server health endpoint
    port = free_port
    pid = fork do
      exec bin/"claude-cto", "server", "start", "--port", port.to_s
    end
    sleep 5
    
    begin
      output = shell_output("curl -s http://localhost:#{port}/health 2>&1", 0)
      assert_match(/healthy|ok/i, output)
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end

    # Test Python module import
    system libexec/"bin/python", "-c", "import claude_cto; print('Import successful')"
  end

  def caveats
    <<~EOS
      🗿 claude-cto has been installed!

      To start the server:
        claude-cto server start

      To run as a service:
        brew services start yigitkonur/claude-cto/claude-cto

      Configuration directory:
        #{var}/claude-cto

      Log directory:
        #{var}/log/claude-cto

      MCP Integration:
      To use with Claude Desktop, add to your config:
        claude mcp add claude-cto -s user -- python -m claude_cto.mcp.factory

      Documentation:
        https://github.com/yigitkonur/claude-cto

      Note: You may need to configure your Anthropic API key:
        export ANTHROPIC_API_KEY="your-key-here"
      
      Or use Claude CLI authentication:
        claude auth login
    EOS
  end
end