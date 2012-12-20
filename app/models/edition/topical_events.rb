module Edition::TopicalEvents
  extend ActiveSupport::Concern
  include Edition::Classifications

  included do
    has_many :topical_events, through: :classification_memberships, source: :topical_event
  end

  def can_be_associated_with_topical_events?
    true
  end

end
