module Document::NationalApplicability
  extend ActiveSupport::Concern

  included do
    has_many :nation_inapplicabilities, foreign_key: :document_id
    has_many :inapplicable_nations, through: :nation_inapplicabilities, source: :nation

    accepts_nested_attributes_for :nation_inapplicabilities, allow_destroy: true
  end

  def can_apply_to_subset_of_nations?
    true
  end

  def build_nation_applicabilities_for_all_nations
    (Nation.all.map(&:id) - nation_inapplicabilities.map(&:nation_id)).each do |nation_id|
      nation_inapplicabilities.build(nation_id: nation_id)
    end
    nation_inapplicabilities.sort_by! { |na| na.nation_id }
  end

end