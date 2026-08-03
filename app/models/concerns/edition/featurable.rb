module Edition::Featurable
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_draft_creation(edition)
      edition.feature_lists = @edition.feature_lists.map(&:deep_clone)
      link_mapping = @edition.clone_offsite_links_to(edition)
      edition.update_featured_offsite_links(link_mapping)
    end
  end

  included do
    has_many :feature_lists, as: :featurable, dependent: :destroy do
      def build_for_locale(locale)
        target.detect(-> { build(locale:) }) { |fl| locale.match?(fl.locale) }
      end
    end
    has_many :offsite_link_parents, as: :parent
    has_many :offsite_links, through: :offsite_link_parents
    add_trait Trait
  end

  def feature_list_for_locale(locale)
    feature_lists.find_by(locale:) || feature_lists.build_for_locale(locale)
  end

  def load_or_create_feature_list(locale = nil)
    locale = I18n.default_locale if locale.blank?
    feature_lists.find_by(locale:) || feature_lists.create!(locale:)
  end

  def build_feature_list_for_locale(locale)
    feature_lists.target.select { |feature_list| feature_list.locale == locale }
  end

  def clone_offsite_links_to(new_edition)
    link_mapping = {}
    offsite_links.each do |old_link|
      new_link = old_link.dup
      new_edition.offsite_link_parents.create!(offsite_link: new_link)
      link_mapping[old_link.id] = new_link
    end
    link_mapping
  end

  def update_featured_offsite_links(link_mapping)
    feature_lists.each do |feature_list|
      feature_list.features.each do |feature|
        new_link = link_mapping[feature.offsite_link_id]
        feature.update!(offsite_link: new_link) if new_link
      end
    end
  end

  def remove_orphaned_offsite_links
    offsite_links_for_edition = offsite_links.to_a
    offsite_link_parents.destroy_all
    offsite_links_for_edition.each do |link|
      link.destroy! if link.offsite_link_parents.reload.empty?
    end
  end
end
