class Admin::TopicalEventOrganisationsController < Admin::BaseController
  before_action :load_topical_event
  layout "design_system"
  def index; end

  def reorder; end

  def order
    params[:ordering].each do |topical_event_organisation_id, ordering|
      @topical_event.topical_event_organisations.where(lead: true).find(topical_event_organisation_id).update_column(:lead_ordering, ordering)
    end

    Whitehall::PublishingApi.republish_async(@topical_event)

    redirect_to polymorphic_path([:admin, @topical_event, :topical_event_organisations]), notice: "Lead organisations have been reordered."
  end

  def toggle_lead
    topical_event_organisation = TopicalEventOrganisation.find(params[:id])
    lead = topical_event_organisation.lead
    @topical_event.topical_event_organisations.find(topical_event_organisation.id).update!(
      lead ? { lead: false, lead_ordering: nil } : { lead: true, lead_ordering: @topical_event.lead_topical_event_organisations.count },
    )

    Whitehall::PublishingApi.republish_async(@topical_event)

    redirect_to polymorphic_path([:admin, @topical_event, :topical_event_organisations]), notice: "#{topical_event_organisation.organisation.name} has been assigned as a #{lead ? 'supporting' : 'lead'} organisation."
  end

private

  def load_topical_event
    @topical_event = TopicalEvent.find(params[:topical_event_id])
  end
end
