module Edition::Scopes::FilterableByTopicalEvent
  extend ActiveSupport::Concern

  included do
    # NOTE: this scope becomes redundant once Admin::EditionFilterer is backed by an admin-only search_api index
    scope :with_topical_event, lambda { |topical_event|
      joins("INNER JOIN topical_event_memberships ON topical_event_memberships.edition_id = editions.id")
        .where("topical_event_memberships.topical_event_id" => topical_event.id)
    }
  end
end
