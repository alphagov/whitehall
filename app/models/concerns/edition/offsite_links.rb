module Edition::OffsiteLinks
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.offsite_links.each do |association|
        edition.offsite_links.build(association.attributes.except("id"))
      end
    end
  end

  included do
    has_many :offsite_links, as: :parent

    add_trait Trait
  end
end
