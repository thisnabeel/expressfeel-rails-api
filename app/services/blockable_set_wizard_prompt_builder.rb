# Builds the same combined prompt + expected JSON shape as the languages/chapters blockable UI.
class BlockableSetWizardPromptBuilder
  class << self
    def build_combined_prompt(set:, payload_text:)
      set = ensure_associations_loaded(set)

      chunks = []
      set_bullets = format_rule_bullets(set.language_chapter_blockable_prompt_rules)
      chunks << set_bullets if set_bullets.present?

      option_chunks = []
      option_key_rows(set).each do |row|
        sec = format_option_section(row[:option], row[:key])
        option_chunks << sec if sec.present?
      end

      if option_chunks.any?
        chunks << "For each give:\n\n#{option_chunks.join("\n\n")}"
      end

      main =
        if chunks.empty?
          "(No rules defined yet.)"
        else
          chunks.join("\n\n")
        end

      pt = payload_text.to_s.strip
      if pt.present?
        payload_line = "Payload: #{pt}"
        main =
          if main == "(No rules defined yet.)"
            payload_line
          else
            "#{main}\n\n#{payload_line}"
          end
      end

      main
    end

    def build_expected_json_string(set:)
      set = ensure_associations_loaded(set)
      keys = option_key_rows(set).map { |r| r[:key] }
      return "[]" if keys.empty?

      row = keys.index_with { |_k| "String" }
      arr = [row, row]
      JSON.pretty_generate(arr)
    end

    def display_keys_for_set(set:)
      set = ensure_associations_loaded(set)
      rows = option_key_rows(set)
      return {} if rows.empty?

      pk = rows.find { |r| r[:option].display == "display" }&.dig(:key) || rows.first[:key]
      sk = rows.find { |r| r[:option].display == "sub" }&.dig(:key)
      sk = nil if sk.present? && sk == pk
      sk ||= rows.find { |r| r[:key] != pk }&.dig(:key)

      out = { "primary" => pk }
      out["sub"] = sk if sk.present?
      out
    end

    # JSON field name (option row key) => { display:, position: } for block item rows.
    def option_metadata_by_key_for_set(set:)
      set = ensure_associations_loaded(set)
      option_key_rows(set).index_by { |r| r[:key] }.transform_values do |r|
        { display: r[:option].display, position: r[:option].position }
      end
    end

    private

    def ensure_associations_loaded(set)
      return set if set.association(:language_chapter_blockable_options).loaded?

      LanguageChapterBlockableSet.includes(
        { language_chapter_blockable_options: :language_chapter_blockable_prompt_rules },
        :language_chapter_blockable_prompt_rules
      ).find(set.id)
    end

    def option_key_rows(set)
      used = Set.new
      rows = []
      set.language_chapter_blockable_options.ordered.each do |o|
        base = o.title.to_s.strip.presence || "option_#{o.id}"
        k = base
        i = 0
        while used.include?(k)
          i += 1
          k = "#{base} (#{i})"
        end
        used.add(k)
        rows << { option: o, key: k }
      end
      rows
    end

    def sorted_rules(relation)
      relation.to_a.sort_by { |r| [r.position || 0, r.id || 0] }
    end

    def format_rule_bullets(relation)
      bodies = sorted_rules(relation).map { |r| r.body.to_s.strip }.reject(&:blank?)
      lines = []
      bodies.each do |body|
        parts = body.split(/\n+/).map(&:strip).reject(&:blank?)
        next if parts.empty?

        lines << "- #{parts[0]}"
        parts[1..].each { |p| lines << "  #{p}" }
      end
      lines.join("\n").presence
    end

    def format_option_section(opt, title_key)
      bullets = format_rule_bullets(opt.language_chapter_blockable_prompt_rules)
      return nil if bullets.blank?

      "#{title_key}:\n#{bullets}"
    end
  end
end
