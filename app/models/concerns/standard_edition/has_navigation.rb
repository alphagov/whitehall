module StandardEdition::HasNavigation
  extend ActiveSupport::Concern

  included do
    has_one :navigation_edition, foreign_key: :edition_id
    has_one :navigation, through: :navigation_edition

    after_create :create_navigation, if: :allows_navigation?
  end

  MAX_CHILD_PAGES_IN_NAV = 7

  def allows_navigation?
    type_instance.settings["navigation_enabled"]
  end

private

  def create_navigation
    create_navigation_edition!(navigation: Navigation.create!(content_id: SecureRandom.uuid))
  end
end
