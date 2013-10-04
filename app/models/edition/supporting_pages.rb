module Edition::SupportingPages
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      @edition.supporting_pages.each do |sd|
        new_supporting_page = edition.supporting_pages.create(sd.attributes.except("id", "edition_id"))
        new_supporting_page.update_column(:slug, sd.slug)
        sd.attachments.each do |attachment|
          new_supporting_page.attachments << attachment.class.new(attachment.attributes)
        end
      end
    end
  end

  included do
    has_many :supporting_pages, foreign_key: :edition_id, dependent: :delete_all

    add_trait Trait
  end

  def allows_supporting_pages?
    true
  end

  def has_supporting_pages?
    supporting_pages.any?
  end
end