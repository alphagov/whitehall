module StandardEdition::Navigation
  extend ActiveSupport::Concern

  MAX_CHILD_PAGES_IN_NAV = 7

  def allows_navigation?
    type_instance.settings["navigation_enabled"]
  end
end
