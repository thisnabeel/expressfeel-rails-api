class PhraseOrderingsController < ApplicationController
  before_action :set_phrase_ordering, only: %i[ show update destroy ]

  # GET /phrase_orderings
  # GET /phrase_orderings.json
  def index
    @phrase_orderings = PhraseOrdering.all
  end

  # GET /phrase_orderings/1
  # GET /phrase_orderings/1.json
  def show
  end

  # POST /phrase_orderings
  # POST /phrase_orderings.json
  def create
    @phrase_ordering = PhraseOrdering.new(phrase_ordering_params)

    if @phrase_ordering.save
      render json: @phrase_ordering, status: :created
    else
      render json: @phrase_ordering.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /phrase_orderings/1
  # PATCH/PUT /phrase_orderings/1.json
  def update
    if @phrase_ordering.update(phrase_ordering_params)
      render json: @phrase_ordering, status: :ok
    else
      render json: @phrase_ordering.errors, status: :unprocessable_entity
    end
  end

  # DELETE /phrase_orderings/1
  # DELETE /phrase_orderings/1.json
  def destroy
    @phrase_ordering.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phrase_ordering
      @phrase_ordering = PhraseOrdering.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def phrase_ordering_params
      params.require(:phrase_ordering).permit(
        :id,
        :category,
        :description,
        :position,
        :phrase_id,
        line: [:ref_index, :optional]
      )
    end
end
