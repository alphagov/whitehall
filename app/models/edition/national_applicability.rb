module Edition::NationalApplicability
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      na_attributes = @edition.nation_inapplicabilities.map do |na|
        na.attributes.except("id")
      end
      edition.nation_inapplicabilities_attributes = na_attributes
    end
  end

  included do
    has_many :nation_inapplicabilities, foreign_key: :edition_id, dependent: :destroy
    has_many :inapplicable_nations, through: :nation_inapplicabilities, source: :nation

    accepts_nested_attributes_for :nation_inapplicabilities, allow_destroy: true

    add_trait Trait
  end

  def can_apply_to_subset_of_nations?
    true
  end

  def build_nation_applicabilities_for_all_nations
    (Nation.potentially_inapplicable.map(&:id) - nation_inapplicabilities.map(&:nation_id)).each do |nation_id|
      nation_inapplicabilities.build(nation_id: nation_id)
    end
    nation_inapplicabilities.sort_by! { |na| na.nation_id }
  end

end