module Document::Identifiable
  extend ActiveSupport::Concern

  included do
    belongs_to :document_identity
    validates :document_identity, presence: true
    before_validation :set_document_identity, on: :create
    before_validation :update_document_identity_slug, on: :update
  end

  def set_document_identity
    self.document_identity ||= DocumentIdentity.new(sluggable_string: self.title)
  end

  def update_document_identity_slug
    self.document_identity.update_slug_if_possible(self.title)
  end

  module ClassMethods
    def published_as(id)
      begin
        identity = DocumentIdentity.find(id)
        identity && identity.published_document
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end
  end
end