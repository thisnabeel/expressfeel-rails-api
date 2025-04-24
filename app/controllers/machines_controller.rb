class MachinesController < ApplicationController
  before_action :set_machine, only: [:show, :edit, :update, :destroy]
  # before_action :check_admin!, only: [:new, :edit, :create, :update, :destroy]

  # GET /machines
  # GET /machines.json
  def index
    @machines = Machine.all.order("position ASC")
  end

  def by_language
    render json: Machine.where(language_id: params[:id]).order("title ASC").map{ |machine| machine.attributes.merge(
        {
          reactions: machine.reactions
        }
      )
    }
  end

  # GET /machines/1
  # GET /machines/1.json
  def show
  end

  # GET /machines/new
  def new
    @machine = Machine.new
  end

  # GET /machines/1/edit
  def edit
  end

  # POST /machines
  # POST /machines.json
  def create
    @machine = Machine.new(machine_params)
  end

  # PATCH/PUT /machines/1
  # PATCH/PUT /machines/1.json
  def update
  end

  # DELETE /machines/1
  # DELETE /machines/1.json
  def destroy
    @machine.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_machine
      @machine = Machine.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def machine_params
      params.require(:machine).permit!
    end
end
