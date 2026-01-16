class WordBlocksController < ApplicationController
  def index
    scope = WordBlock.includes(:language)
    scope = scope.where(language_id: params[:language_id]) if params[:language_id].present?

    if params[:q].present?
      term = "%#{params[:q].strip}%"
      scope = scope.where(
        "unaccent(original) ILIKE unaccent(?) OR unaccent(roman) ILIKE unaccent(?)",
        term,
        term
      )
    end

    word_blocks = scope.order(:original).limit(50)
    render json: word_blocks.as_json(only: [:id, :original, :roman, :english, :language_id])
  end
end


