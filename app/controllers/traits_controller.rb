class TraitsController < ApplicationController
  before_action :set_trait, only: [:show, :edit, :update, :destroy]

  # GET /traits
  # GET /traits.json
  def index
    @traits = Trait.all_cached
  end

  def cached
    @traits = Trait.all_cached
    render json: @traits
  end

  def refresh_traits
    @traits = Trait.refresh_cache
    render json: @traits
  end


  # GET /traits/1
  # GET /traits/1.json
  def show
  end

  # GET /traits/new
  def new
    @trait = Trait.new
  end

  # GET /traits/1/edit
  def edit
  end

  # POST /traits
  # POST /traits.json
  def create
    @trait = Trait.new(trait_params)
  end

  # PATCH/PUT /traits/1
  # PATCH/PUT /traits/1.json
  def update
    render json: @trait.save
  end

  # DELETE /traits/1
  # DELETE /traits/1.json
  def destroy
    @trait.destroy
  end

  def sort_traits

    params[:list].each do |l|
      Trait.find(l["id"]).update(position: l["position"].to_i)
    end
    render status: 200, json: {
      message: "Success!",
    }.to_json

  end

  def config_traits
    # Get List Array
    list = params[:list]

    puts list

    # Each Trait
    list.each do |t|
      # Find Trait
      trait = Trait.find(t["id"])
      # trait.update(trait_id: nil)
      trait.update(
        position: t["position"],
        trait_id: t["belongs"],
      )
    end

    render status: 200, json: {
      message: "Successfully saved map!",
    }.to_json
  end

# 
  def test
  end

# 
  def search
    if params[:search] == ""

      @traits = Trait.order("RANDOM()").limit(10)
    else
      @traits = Trait.where('title ILIKE ? OR title ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%")
    end

    render json: @traits
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trait
      @trait = Trait.find_by(code: params[:id]) || Trait.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trait_params
      params.require(:trait).permit!
    end
end
