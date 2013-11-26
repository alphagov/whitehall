class ClassificationsController < PublicFacingController
  enable_request_formats index: [:atom], show: [:atom]

  include CacheControlHelper

  def index
    @topics = Topic.alphabetical.all
    @topical_events = TopicalEvent.active.alphabetical.all #TODO: with_assosicated_content
  end
end
