# Shared English hint translation for chapter layer items (WizardService).
class LayerItemHintTranslator
  def self.plain_text(html)
    fragment = Nokogiri::HTML::DocumentFragment.parse(html.to_s)
    fragment.text.to_s.gsub(/\s+/, " ").strip
  end

  def self.previous_source_lines_for_item(item, limit: 3)
    item.chapter_layer
      .chapter_layer_items
      .where("position < ?", item.position)
      .order(position: :desc, id: :desc)
      .limit(limit)
      .to_a
      .reverse
      .map { |it| plain_text(it.body) }
      .reject(&:blank?)
  end

  # prior_passage_pairs: [{ "source" => "", "translation" => "" }, ...]
  # If nil/empty, uses previous_source_lines (numbered source-only context).
  def self.translate(source_text, language_title:, prior_passage_pairs: nil, previous_source_lines: nil)
    return "" if source_text.blank?

    lang = language_title.to_s.presence || "the source language"
    context_block = passage_context_block(
      prior_passage_pairs: prior_passage_pairs,
      previous_source_lines: previous_source_lines
    )

    prompt = <<~PROMPT
      Translate this sentence from #{lang} to English.
      Return JSON with exactly this key: translation.
      Value must be plain English text only.
      Do NOT add explanations, notes, hints, labels, markdown, bullets, or quotes.
      Keep proper nouns as proper nouns.
      Use the earlier lines only as context for natural flow, tone, and continuity.
      Translate ONLY the target sentence below, not the earlier lines.

      Earlier in this passage (source → English where known):
      #{context_block}

      Target sentence:
      #{source_text}
    PROMPT

    wizard_json = WizardService.ask(prompt, "json_object")
    normalize_translation(wizard_json["translation"])
  end

  def self.passage_context_block(prior_passage_pairs:, previous_source_lines:)
    if prior_passage_pairs.present?
      prior_passage_pairs.map.with_index(1) do |p, idx|
        src = p["source"].to_s
        tr = p["translation"].to_s
        en = tr.present? ? tr : "(no English yet — infer tone from surrounding lines)"
        "#{idx}. #{src} → #{en}"
      end.join("\n")
    elsif previous_source_lines.present?
      previous_source_lines.map.with_index(1) { |line, idx| "#{idx}. #{line}" }.join("\n")
    else
      "None"
    end
  end

  def self.normalize_translation(raw)
    s = raw.to_s.strip
    s = s.split(/(?:\bHint\b|\bExplanation\b|\bNote\b)\s*:/i).first.to_s.strip
    s = s.sub(/\ATranslation\s*:\s*/i, "").strip
    s = s.gsub(/\A```[a-zA-Z0-9_-]*\s*/m, "").gsub(/```\z/m, "").strip
    s = s.gsub(/\A["'`]+|["'`]+\z/, "").strip
    s = s.lines.first.to_s.strip if s.include?("\n")
    s
  end
end
