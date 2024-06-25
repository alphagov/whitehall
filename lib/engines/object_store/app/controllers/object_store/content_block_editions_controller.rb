class ObjectStore::ContentBlockEditionsController < ApplicationController
  include ObjectStore::Engine.routes.url_helpers

  before_action :check_object_store_feature_flag
  before_action :set_content_block_edition, only: %i[show update destroy]

  def info
    block_type = params.require(:block_type)
    @schema = ObjectStore::ContentBlockValidator.schema_for(block_type)
    render json: @schema
  end

  def index
    @content_block_editions = ObjectStore::ContentBlockEdition.all
  end

  def show
    render json: @content_block_edition
  end

  def new
    block_type = params.require(:block_type)
    properties = block_properties(block_type)

    @content_block_edition = ObjectStore::ContentBlockEdition.new(block_type:, properties:)
  end

  def create
    block_type = params.require(:content_block).require(:block_type)
    properties = content_block_params["properties"]

    @content_block_edition = ObjectStore::ContentBlockEdition.new(block_type:, properties:)

    if @content_block_edition.save
      render json: @content_block_edition, status: :created
    else
      render json: @content_block_edition.errors, status: :unprocessable_entity
    end
  rescue StandardError => e
    # TODO: catch specific invalid json error
    render json: { error: e.message }, status: :unprocessable_entity
  end

private

  def block_properties(block_type)
    @schema = ObjectStore::ContentBlockValidator.schema_for(block_type)

    permitted_params = params.permit(@schema["properties"].keys, :block_type)

    ObjectStore::ContentBlockValidator.default_properties(block_type).merge(permitted_params.to_h.except(:block_type))
  end

  def set_content_block_edition
    @content_block_edition = ContentBlockEdition.find(params[:id])
  end

  def content_block_params
    params.require(:content_block).permit("block_type", "properties" => {})
  end

  def check_object_store_feature_flag
    forbidden! unless Flipflop.object_store?
  end
end
