module Edition::OffsiteLinks
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.edition_offsite_links.each do |association|
        edition.edition_offsite_links.build(association.attributes.except("id"))
      end
    end
  end

  included do
    has_many :edition_offsite_links, foreign_key: :edition_id, dependent: :destroy
    has_many :offsite_links, through: :edition_offsite_links, validate: false

    add_trait Trait
  end
end
