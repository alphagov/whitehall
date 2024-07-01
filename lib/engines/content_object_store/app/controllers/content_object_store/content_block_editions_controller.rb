class ContentObjectStore::ContentBlockEditionsController < ApplicationController
  include ContentObjectStore::Engine.routes.url_helpers
  include Whitehall::Application.routes.url_helpers
  def index
    @content_block_editions = ContentObjectStore::ContentBlockEdition.all
  end
end
