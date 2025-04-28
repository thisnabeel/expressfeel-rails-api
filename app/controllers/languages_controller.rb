class LanguagesController < ApplicationController
  before_action :set_language, only: [:show, :edit, :update, :destroy, :lessons, :phrases, :material_tag_options]

  # GET /languages
  # GET /languages.json
  def index
    @languages = Language.all.order("title ASC")
    render json: @languages, each_serializer: LanguageSerializer, language_only: true
  end

  def populated
    @languages = Language.populated.order("title ASC")
    render json: @languages, each_serializer: LanguageSerializer, language_only: true
  end

  # GET /languages/1
  # GET /languages/1.json
  def show
    render json: @language, serializer: LanguageSerializer
  end

  def material_tag_options
    render json: @language.material_tag_options
  end

  def quiz
    phrase = Language.find(params[:id]).phrases.where(ready: true).sample
    render json: BlocksQuiz.make(phrase)
  end

  def lessons
    lessons = Lesson.left_outer_joins(:phrases)
      .select('lessons.*, phrases.language_id AS phrase_language_id, phrases.ready AS phrase_ready')
      .order(:position)

    lessons_grouped = lessons.group_by(&:id).map do |_, group|
      lesson = group.first

      # Check if any of the joined phrases matches the language AND is ready
      has_matching_phrase = group.any? do |g|
        g.phrase_language_id == params[:id].to_i && g.phrase_ready
      end

      lesson.as_json.merge(empty: !has_matching_phrase)
    end

    render json: lessons_grouped
  end

  # GET /languages/new
  def new
    @language = Language.new
  end

  # GET /languages/1/edit
  def edit
  end

  # POST /languages
  # POST /languages.json
  def create
    @language = Language.new(language_params)
    if @language.save
      render json: @language
    else
      render json: @language.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /languages/1
  # PATCH/PUT /languages/1.json
  def update
    if @language.update(language_params)
      render json: @language
    end
  end

  # DELETE /languages/1
  # DELETE /languages/1.json
  def destroy
    @language.destroy
  end

  def phrases
    render json: @language.phrases, each_serializer: PhraseSerializer
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_language
      @language = Language.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def language_params
      params.require(:language).permit!
    end
end
