module Edition::UserNeeds
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.edition_user_needs.each do |association|
        edition.edition_user_needs.build(association.attributes.except("id"))
      end
    end
  end

  included do
    has_many :edition_user_needs, foreign_key: :edition_id, dependent: :destroy, autosave: true
    has_many :user_needs, through: :edition_user_needs

    accepts_nested_attributes_for :user_needs, reject_if: lambda { |attrs|
      attrs.reject { |k, _| k == "organisation_id" }.values.all?(&:blank?)
    }

    validates_presence_of :user_needs, unless: lambda {|edition| edition.deleted? || edition.imported? }

    add_trait Trait
  end

  def requires_user_needs?
    true
  end
end
