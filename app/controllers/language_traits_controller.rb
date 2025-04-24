class LanguageTraitsController < ApplicationController
  before_action :set_language_trait, only: [:show, :edit, :update, :destroy]

  # GET /language_traits
  # GET /language_traits.json
  def index
    @language_traits = LanguageTrait.all
  end

  # GET /language_traits/1
  # GET /language_traits/1.json
  def show
  end

  # GET /language_traits/new
  def new
    @language_trait = LanguageTrait.new
  end

  # GET /language_traits/1/edit
  def edit
  end

  def fetch_factory
    if params[:language_id].present? && params[:trait_id].present?
      lt = LanguageTrait.where(language_id: params[:language_id], trait_id: params[:trait_id]).first
      if lt.present?
        render json: lt
      else 
        render :json => { :errors => "Error" }
      end
    end
  end

  def factory_save
    if params[:language_id].present? && params[:trait_id].present?
      lt = LanguageTrait.where(language_id: params[:language_id], trait_id: params[:trait_id]).first
      unless lt.present?
        lt = LanguageTrait.create(language_id: params[:language_id], trait_id: params[:trait_id])
      end
      lt.update(body: params[:body])
      render json: lt
    end
  end

  # POST /language_traits
  # POST /language_traits.json
  def create
    @language_trait = LanguageTrait.new(language_trait_params)
  end

  # PATCH/PUT /language_traits/1
  # PATCH/PUT /language_traits/1.json
  def update
  end

  # DELETE /language_traits/1
  # DELETE /language_traits/1.json
  def destroy
    @language_trait.destroy
  end

  def make 
    @language = Language.find(params[:language_id])
    all_traits = Trait.all
    # @selected_traits = Trait.find(params[:traits])
    lts = @language.language_traits

    all_traits.each do |t|
      if lts.where(trait_id: t.id).present?
        lt = lts.where(trait_id: t.id).first
      else
        lt = LanguageTrait.create(trait_id: t.id, language_id: @language.id)
      end
    end

    @language.language_traits.update_all(active: false)
    @language.language_traits.where(trait_id: params[:traits]).update_all(active: true)



    render status: 200, json: {
      message: @language.language_traits,
    }.to_json

  end

  # 
  def lang_concept
    render json: LanguageTrait.where(
      trait_id: params[:trait_id],
      language_id: params[:language_id]).try(:first)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_language_trait
      @language_trait = LanguageTrait.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def language_trait_params
      params.require(:language_trait).permit!
    end
end
