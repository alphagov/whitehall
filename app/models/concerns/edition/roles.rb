module Edition::Roles
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.edition_roles.each do |association|
        edition.edition_roles.build(association.attributes.except("id", "edition_id"))
      end
    end
  end

  included do
    has_many :edition_roles, foreign_key: :edition_id, inverse_of: :edition, dependent: :destroy, autosave: true
    has_many :roles, through: :edition_roles

    add_trait Trait
  end

  def can_be_associated_with_roles?
    true
  end
end
