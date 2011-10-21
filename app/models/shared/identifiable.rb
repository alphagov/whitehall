module Shared
  module Identifiable
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
        identity = DocumentIdentity.from_param(id)
        identity && identity.published_document
      end
    end
  end
end