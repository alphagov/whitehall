module Edition::NationalApplicability
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.nation_inapplicabilities.each do |na|
        edition.nation_inapplicabilities.build(na.attributes.except("id"))
      end
    end
  end

  included do
    has_many :nation_inapplicabilities, foreign_key: :edition_id, dependent: :destroy, autosave: true
    validates_associated :nation_inapplicabilities

    add_trait Trait
  end

  def nation_inapplicabilities_attributes=(attributes)
    attributes.each_value do |params|
      existing = nation_inapplicabilities.detect { |ni| ni.nation_id == params[:nation_id].to_i }

      if ActiveRecord::Type::Boolean.new.deserialize(params[:excluded])
        if existing
          existing.attributes = params.except(:excluded, :id)
        else
          nation_inapplicabilities.build(params)
        end
      elsif existing
        existing.mark_for_destruction
        existing.excluded = params[:excluded]
      end
    end
  end

  def inapplicable_nations
    nation_inapplicabilities.map(&:nation)
  end

  def applicable_nations
    Nation.all - inapplicable_nations
  end

  def can_apply_to_subset_of_nations?
    true
  end

  def national_applicability
    nations = universally_applicable

    inapplicabilities = nation_inapplicabilities
    nations = inapplicabilities.reduce(nations) { |hash, inapplicability|
      key = nation_to_sym(inapplicability.nation.name)
      hash[key][:applicable] = false
      hash[key][:alternative_url] = inapplicability.alternative_url if inapplicability.alternative_url
      hash
    }

    nations
  end

private

  def nation_to_sym(nation)
    nation.tr(' ', '_').downcase.to_sym
  end

  def universally_applicable
    all_nations = %w(England Northern\ Ireland Scotland Wales)
    all_nations.reduce({}) { |hash, nation|
      key = nation_to_sym(nation)
      hash[key] = {
        label: nation,
        applicable: true
      }
      hash
    }
  end
end
