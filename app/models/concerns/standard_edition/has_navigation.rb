module StandardEdition::HasNavigation
  extend ActiveSupport::Concern

  included do
    has_one :navigation_edition, foreign_key: :edition_id
  end

  MAX_CHILD_PAGES_IN_NAV = 7

  def allows_navigation?
    type_instance.settings["navigation_enabled"]
  end
end
