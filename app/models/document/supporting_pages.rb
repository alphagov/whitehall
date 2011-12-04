module Document::SupportingPages
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_after_save(document)
      @document.supporting_pages.each do |sd|
        document.supporting_pages.create(sd.attributes.except("document_id"))
      end
    end
  end

  included do
    has_many :supporting_pages, foreign_key: :document_id

    add_trait Trait
  end

  def allows_supporting_pages?
    true
  end

  def has_supporting_pages?
    supporting_pages.any?
  end
end