class PhraseDynamicsController < ApplicationController
  before_action :set_phrase_dynamic, only: %i[ show update destroy ]

  # GET /phrase_dynamics
  # GET /phrase_dynamics.json
  def index
    @phrase_dynamics = PhraseDynamic.all
  end

  # GET /phrase_dynamics/1
  # GET /phrase_dynamics/1.json
  def show
  end

  # POST /phrase_dynamics
  # POST /phrase_dynamics.json
  def create
    @phrase_dynamic = PhraseDynamic.new(phrase_dynamic_params)

    if @phrase_dynamic.save
      # render :show, status: :created, location: @phrase_dynamic
      render json: @phrase_dynamic, serializer: PhraseDynamicSerializer
    else
      render json: @phrase_dynamic.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /phrase_dynamics/1
  # PATCH/PUT /phrase_dynamics/1.json
  def update
    if @phrase_dynamic.update(phrase_dynamic_params)
      render :show, status: :ok, location: @phrase_dynamic
    else
      render json: @phrase_dynamic.errors, status: :unprocessable_entity
    end
  end

  # DELETE /phrase_dynamics/1
  # DELETE /phrase_dynamics/1.json
  def destroy
    @phrase_dynamic.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phrase_dynamic
      @phrase_dynamic = PhraseDynamic.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def phrase_dynamic_params
      params.require(:phrase_dynamic).permit!
    end
end
