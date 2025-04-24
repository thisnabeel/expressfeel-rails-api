class PhraseFactoriesController < ApplicationController
  before_action :set_phrase_factory, only: %i[ show update destroy ]

  # GET /phrase_factories
  # GET /phrase_factories.json
  def index
    @phrase_factories = PhraseFactory.all
  end

  # GET /phrase_factories/1
  # GET /phrase_factories/1.json
  def show
  end

  # POST /phrase_factories
  # POST /phrase_factories.json
  def create
    @phrase_factory = PhraseFactory.new(phrase_factory_params)

    if @phrase_factory.save
      render json: @phrase_factory, serializer: PhraseFactorySerializer
    else
      render json: @phrase_factory.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /phrase_factories/1
  # PATCH/PUT /phrase_factories/1.json
  def update
    if @phrase_factory.update(phrase_factory_params)
      render json: @phrase_factory, serializer: PhraseFactorySerializer
    else
      render json: @phrase_factory.errors, status: :unprocessable_entity
    end
  end

  # DELETE /phrase_factories/1
  # DELETE /phrase_factories/1.json
  def destroy
    @phrase_factory.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phrase_factory
      @phrase_factory = PhraseFactory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def phrase_factory_params
      params.require(:phrase_factory).permit(:phrase_id, :factory_id, :position, :code)
    end
end
