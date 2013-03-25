module Edition::HtmlVersion
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      return unless @edition.html_version
      edition.html_version_attributes = @edition.html_version.attributes.except("id")
      edition.html_version.slug = @edition.html_version.slug
    end
  end

  included do
    has_one :html_version, foreign_key: :edition_id, dependent: :destroy
    accepts_nested_attributes_for :html_version, reject_if: :all_blank_or_empty_hashes

    add_trait Trait
  end
end
