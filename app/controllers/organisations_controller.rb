class OrganisationsController < PublicFacingController
  include CacheControlHelper

  def index
    @content_item = Whitehall.content_store.content_item("/courts-tribunals")
    @courts = Organisation.courts.listable.ordered_by_name_ignoring_prefix
    @hmcts_tribunals = Organisation.hmcts_tribunals.listable.ordered_by_name_ignoring_prefix
    render :courts_index
  end
end
