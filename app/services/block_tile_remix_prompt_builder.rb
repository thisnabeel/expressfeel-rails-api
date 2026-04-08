class BlockTileRemixPromptBuilder
  class << self
    def build(set:, row_hash:, field_key:, current_value:, instruction:)
      # We include the set's rules so the model stays aligned with the language's block-set constraints,
      # but we narrow the expected output to a single string value.
      rules = BlockableSetWizardPromptBuilder.build_combined_prompt(set: set, payload_text: "")

      <<~PROMPT.strip
        You are remixing ONE field in ONE row of a structured JSON table.

        Return ONLY a JSON object with exactly one key:
        - "value": the new string value for the requested field.

        Do NOT return any other keys. Do NOT return "items". No explanations.

        Block-set rules (context; follow them when relevant):
        #{rules}

        Target field key:
        #{field_key}

        Current row (JSON):
        #{row_hash.to_json}

        Current value for "#{field_key}":
        #{current_value.to_s}

        Instruction:
        """
        #{instruction.to_s}
        """
      PROMPT
    end
  end
end

