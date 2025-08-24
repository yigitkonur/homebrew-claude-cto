class ClaudeCto < Formula
  include Language::Python::Virtualenv

  desc "Fire-and-forget task execution system for Claude Code SDK"
  homepage "https://github.com/yigitkonur/claude-cto"
  url "https://files.pythonhosted.org/packages/2b/90/eb71624860525e74306add7cda0f2f72969a0eaa201b301a752a78f1f500/claude_cto-0.5.1.tar.gz"
  sha256 "6b70368d3a8c282335818bd926a17ff4523df5d693028a6de6f760ccd96ba134"
  license "MIT"
  head "https://github.com/yigitkonur/claude-cto.git", branch: "main"

  depends_on "python@3.12"
  depends_on "node" => :recommended  # For Claude CLI integration

  def install
    # Create virtualenv
    venv = virtualenv_create(libexec, "python3.12")
    
    # Install the package with all extras from PyPI
    system libexec/"bin/pip", "install", "--upgrade", "pip"
    system libexec/"bin/pip", "install", "claude-cto[full]==0.5.1"
    
    # Create wrapper scripts for the executables
    bin.install_symlink Dir[libexec/"bin/claude-cto"]
    bin.install_symlink Dir[libexec/"bin/claude-cto-mcp"]

    # Generate shell completions
    generate_completions_from_executable(bin/"claude-cto", shells: [:bash, :zsh, :fish],
                                        shell_parameter_format: :none,
                                        completion_script_generator: proc do |shell|
      case shell
      when :bash
        `#{bin}/claude-cto completion bash 2>/dev/null || echo ""`
      when :zsh
        `#{bin}/claude-cto completion zsh 2>/dev/null || echo ""`
      when :fish
        `#{bin}/claude-cto completion fish 2>/dev/null || echo ""`
      end
    end)

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
    assert_match "0.5", shell_output("#{bin}/claude-cto --version 2>&1", 0)

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