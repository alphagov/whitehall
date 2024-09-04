class Api::MinistersController < ApplicationController
  def index
    presenter = Api::MinistersPresenter.new()
    render json: presenter.content
  end
end
