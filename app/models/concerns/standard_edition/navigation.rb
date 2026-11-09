module StandardEdition::Navigation
  extend ActiveSupport::Concern

  def allows_navigation?
    type_instance.settings["navigation_enabled"]
  end
end
