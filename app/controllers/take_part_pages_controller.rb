class TakePartPagesController < PublicFacingController
  layout 'frontend'

  def show
    @take_part_page = TakePartPage.friendly.find(params[:id])
  end
end
