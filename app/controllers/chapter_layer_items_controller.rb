class ChapterLayerItemsController < ApplicationController
  include ApiAuthenticatable

  before_action :authenticate_api_admin!
  before_action :set_layer, only: [:create, :reorder, :insert_after]
  before_action :set_item, only: [:update, :destroy]

  def create
    @item = @layer.chapter_layer_items.new(item_params)
    if @item.save
      render json: @item.as_json, status: :created
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  # POST /chapter_layers/:chapter_layer_id/chapter_layer_items/insert_after
  # body: { after_id: optional item id, chapter_layer_item: { body, style, hint } }
  # Efficient middle insert: one bulk shift + one insert in a transaction.
  def insert_after
    after_id = params[:after_id]
    insert_pos = if after_id.present?
      ref = @layer.chapter_layer_items.find(after_id)
      ref.position + 1
    else
      0
    end

    created = nil
    ChapterLayerItem.transaction do
      @layer.chapter_layer_items.where("position >= ?", insert_pos).update_all("position = position + 1")
      created = @layer.chapter_layer_items.create!(item_params.merge(position: insert_pos))
    end

    render json: created.as_json, status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: "after_id not found in this layer" }, status: :unprocessable_entity
  end

  def update
    if @item.update(item_params)
      render json: @item.as_json
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy!
    head :no_content
  end

  def reorder
    ids = params.require(:ordered_ids)
    unless ids.is_a?(Array)
      return render json: { error: "ordered_ids must be an array" }, status: :unprocessable_entity
    end

    ChapterLayerItem.transaction do
      ids.each_with_index do |item_id, idx|
        @layer.chapter_layer_items.find(item_id).update!(position: idx)
      end
    end
    head :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Invalid item id" }, status: :unprocessable_entity
  end

  private

  def set_layer
    @layer = ChapterLayer.find(params[:chapter_layer_id])
  end

  def set_item
    @item = ChapterLayerItem.find(params[:id])
  end

  def item_params
    params.require(:chapter_layer_item).permit(:body, :style, :hint, :position)
  end
end
