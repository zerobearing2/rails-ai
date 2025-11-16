# frozen_string_literal: true

require "open3"
require "json"

# Base adapter class for LLM providers
# Defines the interface that all LLM adapters must implement
class LLMAdapter
  # Execute a prompt and return the response
  # @param prompt [String] The prompt to send to the LLM
  # @param system_prompt [String, nil] Optional system prompt
  # @param streaming [Boolean] Whether to stream the response
  # @param on_chunk [Proc, nil] Callback for streaming chunks (receives text string)
  # @return [String] The complete response text
  def execute(prompt:, system_prompt: nil, streaming: false, on_chunk: nil)
    raise NotImplementedError, "Subclasses must implement #execute"
  end

  # Check if the LLM is available
  # @return [Boolean] true if LLM is available
  def available?
    raise NotImplementedError, "Subclasses must implement #available?"
  end

  # Get the name of this LLM provider
  # @return [String] Provider name
  def name
    raise NotImplementedError, "Subclasses must implement #name"
  end
end

# Claude CLI adapter using stream-json format for real-time streaming
class ClaudeAdapter < LLMAdapter
  def name
    "Claude CLI"
  end

  def available?
    system("which claude > /dev/null 2>&1")
  end

  def execute(prompt:, system_prompt: nil, streaming: false, on_chunk: nil)
    raise "Claude CLI not found. Install from https://docs.anthropic.com/claude-code" unless available?

    if streaming && on_chunk
      execute_streaming(prompt: prompt, system_prompt: system_prompt, on_chunk: on_chunk)
    else
      execute_non_streaming(prompt: prompt, system_prompt: system_prompt)
    end
  end

  private

  def execute_non_streaming(prompt:, system_prompt:)
    cmd = ["claude", "--print"]
    cmd += ["--system-prompt", system_prompt] if system_prompt

    stdout, stderr, status = Open3.capture3(*cmd, stdin_data: prompt)

    unless status.success?
      raise "Claude CLI failed with status #{status.exitstatus}:\nSTDERR: #{stderr}\nSTDOUT: #{stdout}"
    end

    stdout
  end

  def execute_streaming(prompt:, system_prompt:, on_chunk:)
    cmd = ["claude", "--print", "--output-format", "stream-json", "--verbose", "--include-partial-messages"]
    cmd += ["--system-prompt", system_prompt] if system_prompt

    full_text = []
    stderr_output = []

    Open3.popen3(*cmd) do |stdin, stdout, stderr, wait_thr|
      stdin.write(prompt)
      stdin.close

      streams = [stdout, stderr]
      until streams.all?(&:eof?)
        ready = IO.select(streams, nil, nil, 0.05)
        next unless ready

        ready[0].each do |stream|
          chunk = stream.read_nonblock(4096)

          if stream == stdout
            # Parse streaming JSON events
            chunk.each_line do |line|
              next if line.strip.empty?

              begin
                json = JSON.parse(line)

                # Handle stream_event wrapper (with --include-partial-messages)
                if json["type"] == "stream_event" && json["event"]
                  event = json["event"]

                  # Extract text deltas
                  if event["type"] == "content_block_delta" && event.dig("delta", "text")
                    text = event.dig("delta", "text")
                    full_text << text
                    on_chunk&.call(text)
                  end
                elsif json["type"] == "assistant"
                  # Final consolidated message (fallback if streaming didn't capture everything)
                  final_text = json.dig("message", "content", 0, "text")
                  if final_text && full_text.join != final_text
                    # Streaming missed some content, use final message
                    full_text = [final_text]
                  end
                end
              rescue JSON::ParserError
                # Ignore non-JSON lines
              end
            end
          else
            # stderr
            stderr_output << chunk
          end
        rescue IO::WaitReadable
        rescue EOFError
        end
      end

      status = wait_thr.value
      unless status.success?
        error_msg = "Claude CLI failed with status #{status.exitstatus}"
        error_msg += "\nSTDOUT: #{full_text.join}" if full_text.any?
        error_msg += "\nSTDERR: #{stderr_output.join}" if stderr_output.any?
        raise error_msg
      end
    end

    full_text.join
  end
end
