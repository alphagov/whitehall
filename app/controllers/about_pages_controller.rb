class AboutPagesController < PublicFacingController
  def show
    @topical_event = TopicalEvent.find_by!(slug: params[:topical_event_id])
    @about_page = @topical_event.about_page
    raise ActiveRecord::RecordNotFound if @about_page.blank?
  end
end
