# Shared wizard call for blockable-set JSON "items" arrays (same contract as WizardController#block_set_testing).
class BlockableSetWizardRunner
  MAX_PROMPT = 48_000
  MAX_EXPECTED = 24_000
  MAX_SHAPE_ATTEMPTS = 3

  class << self
    def run!(prompt:, expected_json:)
      prompt = prompt.to_s
      expected_json = expected_json.to_s
      if prompt.blank? || expected_json.blank?
        return { ok: false, items: nil, parsed: nil, error: "prompt and expected_json are required" }
      end
      if prompt.length > MAX_PROMPT
        return { ok: false, items: nil, parsed: nil, error: "prompt is too long (max #{MAX_PROMPT})" }
      end
      if expected_json.length > MAX_EXPECTED
        return { ok: false, items: nil, parsed: nil, error: "expected_json is too long (max #{MAX_EXPECTED})" }
      end

      wizard_prompt = <<~PROMPT
        You are testing a "blockable set" configuration for language-processing prompts.

        Return ONLY a JSON object with exactly one top-level key:
        - "items": a JSON array. Each element must be a plain object whose keys match the keys shown in the EXPECTED STRUCTURE sample below (same keys for every row). Fill values with real strings produced by strictly following the INSTRUCTIONS below—do not use the placeholder word "String" unless it is the genuine answer.

        EXPECTED STRUCTURE (array of objects; values are illustrative only):
        #{expected_json}

        INSTRUCTIONS (complete prompt to execute; includes any payload line):
        #{prompt}
      PROMPT

      parsed = nil
      items = nil

      MAX_SHAPE_ATTEMPTS.times do |attempt_index|
        prompt_for_attempt =
          if attempt_index.zero?
            wizard_prompt.strip
          else
            <<~PROMPT.strip
              #{wizard_prompt.strip}

              ---
              RETRY #{attempt_index + 1}/#{MAX_SHAPE_ATTEMPTS}:
              Your previous response did not contain a top-level "items" array.
              Return ONLY valid JSON with this exact top-level shape:
              {"items":[{...}]}
            PROMPT
          end

        parsed = WizardService.ask(prompt_for_attempt, "json_object")
        log_shape_attempt(attempt_index: attempt_index, parsed: parsed)
        items = extract_items_array(parsed)
        break if items.is_a?(Array)
      end

      if items.is_a?(Array)
        { ok: true, items: items, parsed: parsed, error: nil }
      else
        { ok: false, items: nil, parsed: parsed, error: 'Model did not return a top-level "items" array' }
      end
    rescue StandardError => e
      Rails.logger.error("[BlockableSetWizardRunner] #{e.class}: #{e.message}")
      { ok: false, items: nil, parsed: nil, error: e.message.to_s }
    end

    private

    def extract_items_array(parsed)
      return parsed if parsed.is_a?(Array)
      return nil unless parsed.is_a?(Hash)

      items = parsed["items"]
      return items if items.is_a?(Array)

      # Common fallback shapes from model drift.
      %w[data results output rows].each do |k|
        v = parsed[k]
        return v if v.is_a?(Array)
      end

      raw = parsed["raw_response"]
      return nil if raw.blank?

      begin
        reparsed = JSON.parse(raw.to_s)
      rescue JSON::ParserError
        return nil
      end

      return reparsed if reparsed.is_a?(Array)
      return reparsed["items"] if reparsed.is_a?(Hash) && reparsed["items"].is_a?(Array)

      nil
    end

    def log_shape_attempt(attempt_index:, parsed:)
      attempt_no = attempt_index + 1
      begin
        preview =
          if parsed.is_a?(String)
            parsed
          else
            JSON.pretty_generate(parsed)
          end
      rescue StandardError
        preview = parsed.inspect
      end
      preview = preview.to_s
      preview = "#{preview[0, 2000]}...(truncated)" if preview.length > 2000

      shape =
        if parsed.is_a?(Hash)
          keys = parsed.keys.take(12).join(", ")
          "hash keys=[#{keys}] items_class=#{parsed['items'].class.name if parsed.key?('items')}"
        else
          parsed.class.name
        end

      Rails.logger.info("[BlockableSetWizardRunner] attempt #{attempt_no}/#{MAX_SHAPE_ATTEMPTS} parsed shape: #{shape}")
      Rails.logger.info("[BlockableSetWizardRunner] attempt #{attempt_no}/#{MAX_SHAPE_ATTEMPTS} parsed payload: #{preview}")
    end
  end
end
