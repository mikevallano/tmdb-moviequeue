# frozen_string_literal: true

module Claude
  module Client
    class Error < StandardError; end

    # API Docs: https://platform.claude.com/docs
    MODEL = 'claude-sonnet-5-5'
    EFFORT = :medium
    MAX_TOKENS = 16_000
    FALLBACK_BETA = 'server-side-fallback-2026-07-01'
    # Fail before Heroku's 30s router timeout; no retries for the same reason.
    TIMEOUT_SECONDS = 20

    class << self
      # Returns the response parsed from JSON (symbolized keys) matching `schema`.
      def request_json(system:, prompt:, schema:)
        response = client.beta.messages.create(
          model: MODEL,
          max_tokens: MAX_TOKENS,
          system_: system,
          messages: [{ role: :user, content: prompt }],
          output_config: { effort: EFFORT, format: { type: :json_schema, schema: schema } },
          fallbacks: :default,
          betas: [FALLBACK_BETA]
        )
        log_usage(response)
        raise Error, "Claude declined the request (#{response.stop_details&.category})" if response.stop_reason == :refusal
        raise Error, 'Claude response was cut off at max_tokens' if response.stop_reason == :max_tokens

        text = response.content.find { |block| block.type == :text }&.text
        raise Error, 'Claude response had no text' if text.blank?

        JSON.parse(text, symbolize_names: true)
      rescue Anthropic::Errors::Error, JSON::ParserError => e
        raise Error, "#{e.class}: #{e.message}"
      end

      private

      def client
        @client ||= Anthropic::Client.new(
          api_key: ENV.fetch('anthropic_api_key') { raise Error, 'anthropic_api_key is not set' },
          timeout: TIMEOUT_SECONDS,
          max_retries: 0
        )
      end

      def log_usage(response)
        usage = response.usage
        Rails.logger.info(
          "[claude] model=#{response.model} stop_reason=#{response.stop_reason} " \
          "input_tokens=#{usage.input_tokens} output_tokens=#{usage.output_tokens}"
        )
      end
    end
  end
end
