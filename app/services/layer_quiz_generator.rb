class LayerQuizGenerator
  # Generates MCQ quiz JSON for a layer's items.
  # Returns array of quizzes (we store only into one quiz titled "MCQ").
  def self.generate_mcq(layer)
    language_title = layer.chapter&.language&.title.to_s.presence || "the chapter language"

    items = layer.chapter_layer_items.ordered.to_a
    source_lines = items
      .reject { |it| %w[line_break hr].include?(it.style) }
      .map { |it| LayerItemHintTranslator.plain_text(it.body) }
      .reject(&:blank?)

    english_lines = items
      .reject { |it| %w[line_break hr].include?(it.style) }
      .map { |it| it.hint.to_s.strip }
      .reject(&:blank?)

    passage_block = source_lines.first(140).map.with_index(1) { |t, i| "#{i}. #{t}" }.join("\n")
    english_block = english_lines.first(140).map.with_index(1) { |t, i| "#{i}. #{t}" }.join("\n")

    prompt = <<~PROMPT
      You are creating a multiple-choice quiz for language learners.
      The language of \"original\" is #{language_title}. The language of \"english\" is English.

      Use this passage (original language) as the source of questions:
      #{passage_block.presence || "None"}

      If helpful, here are existing English translations (may be incomplete):
      #{english_block.presence || "None"}

      Create 8 to 12 questions. Each question must have:
      - original (question in #{language_title})
      - english (English translation of the question)
      - layer_item_quiz_answers: exactly 4 answers with:
        - original
        - english
        - position (1..4)
        - correct (exactly one true)

      Return JSON with exactly this top-level shape:
      { \"quizzes\": [ { \"title\": \"MCQ\", \"layer_quiz_questions\": [ ... ] } ] }

      Do not include markdown. Do not include extra keys.
    PROMPT

    WizardService.ask(prompt, "json_object")
  end
end

