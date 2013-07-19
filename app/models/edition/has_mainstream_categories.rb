module Edition::HasMainstreamCategories
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.edition_mainstream_categories = @edition.edition_mainstream_categories.map do |emc|
        EditionMainstreamCategory.new(emc.attributes.except(:id))
      end
    end
  end

  included do
    belongs_to :primary_mainstream_category, class_name: "MainstreamCategory"

    has_many :edition_mainstream_categories, dependent: :destroy,
             foreign_key: :edition_id
    has_many :other_mainstream_categories, through: :edition_mainstream_categories,
             source: :mainstream_category

    add_trait Trait

    validate :avoid_duplication_between_primary_and_other_mainstream_categories
    validates :primary_mainstream_category, presence: true, unless: ->(edition) { edition.can_have_some_invalid_data? }
  end

  def mainstream_categories
    [primary_mainstream_category] + other_mainstream_categories
  end

  def can_be_associated_with_mainstream_categories?
    true
  end

  private

  def avoid_duplication_between_primary_and_other_mainstream_categories
    if other_mainstream_categories.include?(primary_mainstream_category)
      errors[:other_mainstream_categories] << "should not contain the primary mainstream category"
    end
  end
end
