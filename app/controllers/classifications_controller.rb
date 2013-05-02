class ClassificationsController < PublicFacingController
  include CacheControlHelper

  def index
    @topics = Topic.with_policies.alphabetical.all
    @topical_events = TopicalEvent.active.alphabetical.all #TODO: with_assosicated_content
  end

end
