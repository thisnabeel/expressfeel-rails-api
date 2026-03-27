class LayerQuizzesController < ApplicationController
  include ApiAuthenticatable

  before_action :authenticate_api_admin!, except: [:index, :show]
  before_action :set_layer, only: [:index, :create, :generate_mcq]
  before_action :set_quiz, only: [:show, :update, :destroy]

  # GET /chapter_layers/:chapter_layer_id/layer_quizzes
  def index
    render json: { layer_quizzes: @layer.layer_quizzes.order(:id).map(&:as_json_for_admin) }
  end

  # GET /layer_quizzes/:id
  def show
    render json: @quiz.as_json_for_admin
  end

  # POST /chapter_layers/:chapter_layer_id/layer_quizzes
  def create
    quiz = @layer.layer_quizzes.create!(quiz_params)
    render json: quiz.as_json_for_admin, status: :created
  end

  # PATCH /layer_quizzes/:id
  def update
    @quiz.update!(quiz_params)
    render json: @quiz.as_json_for_admin
  end

  # DELETE /layer_quizzes/:id
  def destroy
    @quiz.destroy!
    head :no_content
  end

  # POST /chapter_layers/:chapter_layer_id/layer_quizzes/generate_mcq
  # Uses wizard to generate questions + answers for this layer, then overwrites the MCQ quiz.
  def generate_mcq
    payload = LayerQuizGenerator.generate_mcq(@layer)
    quiz_json = (payload["quizzes"].is_a?(Array) ? payload["quizzes"] : []).find { |q| q["title"].to_s.strip == "MCQ" } ||
      (payload["quizzes"].is_a?(Array) ? payload["quizzes"].first : nil)

    unless quiz_json.is_a?(Hash)
      return render json: { error: "Wizard returned invalid quiz JSON" }, status: :unprocessable_entity
    end

    questions = quiz_json["layer_quiz_questions"]
    unless questions.is_a?(Array) && questions.any?
      return render json: { error: "No questions generated" }, status: :unprocessable_entity
    end

    quiz = @layer.layer_quizzes.where(title: "MCQ").first_or_create!(title: "MCQ")

    now = Time.current
    LayerQuizQuestion.transaction do
      # wipe existing MCQ questions+answers
      ids = quiz.layer_quiz_questions.pluck(:id)
      LayerItemQuizAnswer.where(layer_quiz_question_id: ids).delete_all if ids.any?
      quiz.layer_quiz_questions.destroy_all

      q_rows = []
      a_rows = []

      questions.each_with_index do |q, qidx|
        next unless q.is_a?(Hash)

        q_original = q["original"].to_s
        q_english = q["english"].to_s
        q_pos = q["position"].presence || qidx

        q_rows << {
          layer_quiz_id: quiz.id,
          original: q_original,
          english: q_english,
          position: q_pos.to_i,
          created_at: now,
          updated_at: now
        }
      end

      inserted = LayerQuizQuestion.insert_all!(q_rows, returning: %w[id position]) # PG supports RETURNING
      inserted_ids = inserted.rows.map { |row| row[0] }

      # Map answers to inserted questions in order.
      questions.each_with_index do |q, qidx|
        qid = inserted_ids[qidx]
        next unless qid
        ans = q["layer_item_quiz_answers"]
        next unless ans.is_a?(Array)

        ans.each do |a|
          next unless a.is_a?(Hash)
          a_rows << {
            layer_quiz_question_id: qid,
            original: a["original"].to_s,
            english: a["english"].to_s,
            position: a["position"].to_i,
            correct: a["correct"] == true,
            created_at: now,
            updated_at: now
          }
        end
      end

      LayerItemQuizAnswer.insert_all!(a_rows) if a_rows.any?
    end

    @layer.chapter&.refresh_default_layer_caches!
    render json: quiz.reload.as_json_for_admin, status: :created
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_layer
    @layer = ChapterLayer.find(params[:chapter_layer_id])
  end

  def set_quiz
    @quiz = LayerQuiz.find(params[:id])
  end

  def quiz_params
    params.require(:layer_quiz).permit(:title)
  end
end

