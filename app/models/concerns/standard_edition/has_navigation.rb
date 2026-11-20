module StandardEdition::HasNavigation
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_draft_creation(new_edition)
      return unless @edition.navigation

      navigation_edition = new_edition.build_navigation_edition(navigation: @edition.navigation)
      @edition.navigation_edition.navigation_items.each do |navigation_item|
        navigation_edition.navigation_items.build(navigation_item.attributes.except("id", "navigation_edition_id"))
      end
    end
  end

  included do
    has_one :navigation_edition, foreign_key: :edition_id
    has_one :navigation, through: :navigation_edition

    add_trait Trait
    after_create :create_navigation, if: :allows_navigation?
  end

  MAX_CHILD_PAGES_IN_NAV = 7

  def allows_navigation?
    type_instance.settings["navigation_enabled"]
  end

private

  def create_navigation
    return if navigation_edition.present?

    create_navigation_edition!(navigation: Navigation.create!(content_id: SecureRandom.uuid))
  end
end
