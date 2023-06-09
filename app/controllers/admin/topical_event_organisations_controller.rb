class Admin::TopicalEventOrganisationsController < Admin::BaseController
  layout "design_system"
  def index
    @topical_event = TopicalEvent.find(params[:topical_event_id])
  end
end
