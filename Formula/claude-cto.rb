class ClaudeCto < Formula
  include Language::Python::Virtualenv

  desc "Fire-and-forget task execution system for Claude Code SDK"
  homepage "https://github.com/yigitkonur/claude-cto"
  url "https://files.pythonhosted.org/packages/c5/92/e5820c452d716c8f4a69575c8fb19c1dbac4ef97b0cda4971e7c7c8c3894/claude_cto-0.8.0.tar.gz"
  sha256 "a0978d8498bb90fe48a45eff38f8649519305f889f2e91894bb0ee0128d5a423"
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
    system libexec/"bin/python", "-m", "pip", "install", "claude-cto[server,mcp]==0.8.0"
    
    # Create wrapper scripts for the executables
    bin.install_symlink Dir[libexec/"bin/claude-cto"]
    bin.install_symlink Dir[libexec/"bin/claude-cto-mcp"]

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
    assert_match "0.8", shell_output("#{bin}/claude-cto version 2>&1", 0)

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