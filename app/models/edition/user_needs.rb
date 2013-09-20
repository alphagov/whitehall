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

    accepts_nested_attributes_for :user_needs, :reject_if => :all_blank

    validates_presence_of :user_needs

    add_trait Trait
  end
end
