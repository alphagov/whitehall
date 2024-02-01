module Edition::Parted
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.worldwide_organisation_pages.each do |association|
        edition.worldwide_organisation_pages.build(association.attributes.except("id"))
      end
    end
  end

  included do
    add_trait Trait
  end
end
