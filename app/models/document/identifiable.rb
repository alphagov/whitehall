module Document::Identifiable
  extend ActiveSupport::Concern

  included do
    belongs_to :document_identity
    validates :document_identity, presence: true
  end

  def initialize(*args, &block)
    super
    self.document_identity ||= DocumentIdentity.new
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