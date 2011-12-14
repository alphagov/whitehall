class SearchesController < ApplicationController
  helper_method :search_performed?

  def show
    params.delete(:q) if params[:q].blank?
    if search_performed?
      @documents = Document.search(params[:q])
    end
  end

  private

  def search_performed?
    params.has_key?(:q)
  end

end