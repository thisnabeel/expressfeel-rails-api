# Shared wizard call for blockable-set JSON "items" arrays (same contract as WizardController#block_set_testing).
class BlockableSetWizardRunner
  MAX_PROMPT = 48_000
  MAX_EXPECTED = 24_000

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

      parsed = WizardService.ask(wizard_prompt.strip, "json_object")
      items = parsed["items"]
      if items.is_a?(Array)
        { ok: true, items: items, parsed: parsed, error: nil }
      else
        { ok: false, items: nil, parsed: parsed, error: 'Model did not return a top-level "items" array' }
      end
    rescue StandardError => e
      Rails.logger.error("[BlockableSetWizardRunner] #{e.class}: #{e.message}")
      { ok: false, items: nil, parsed: nil, error: e.message.to_s }
    end
  end
end
