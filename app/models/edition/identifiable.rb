module Edition::Identifiable
  extend ActiveSupport::Concern
  extend Forwardable

  included do
    belongs_to :document, foreign_key: :document_id
    validates :document, presence: true
    before_validation :set_document, on: :create
    before_validation :update_document_slug, on: :update
    before_validation :set_document_type_on_document
  end

  def_delegators :document, :slug, :editions_ever_published
  def_delegator :document, :published?, :linkable?

  def set_document
    self.document ||= Document.new(sluggable_string: self.sluggable_title)
  end

  def update_document_slug
    self.document.update_slug_if_possible(self.sluggable_title)
  end

  def set_document_type_on_document
    self.document.set_document_type(type) if document.present?
  end

  module ClassMethods
    def published_as(id)
      begin
        document = Document.where(document_type: sti_name).find(id)
        document && document.published_edition
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end
  end
end
