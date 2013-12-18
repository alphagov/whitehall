module Edition::Ministers
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.ministerial_roles = @edition.ministerial_roles
    end
  end

  included do
    has_many :edition_ministerial_roles, foreign_key: :edition_id, dependent: :destroy
    has_many :ministerial_roles, through: :edition_ministerial_roles

    add_trait Trait
  end

  def can_be_associated_with_ministers?
    true
  end
end
