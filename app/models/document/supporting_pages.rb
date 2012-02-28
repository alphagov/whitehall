module Document::SupportingPages
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_after_save(document)
      @document.supporting_pages.each do |sd|
        new_supporting_page = document.supporting_pages.create(sd.attributes.except("id", "document_id"))
        sd.attachments.each do |a|
          new_supporting_page.supporting_page_attachments.create(attachment_id: a.id)
        end
      end
    end
  end

  included do
    has_many :supporting_pages, foreign_key: :document_id, dependent: :delete_all

    add_trait Trait
  end

  def allows_supporting_pages?
    true
  end

  def has_supporting_pages?
    supporting_pages.any?
  end
end