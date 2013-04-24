class TakePartPagesController < ApplicationController
  layout 'frontend'

  def show
    @take_part_page = TakePartPage.find(params[:id])
  end
end
