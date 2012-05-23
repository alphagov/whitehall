module Edition::Identifiable
  extend ActiveSupport::Concern
  extend Forwardable

  included do
    belongs_to :doc_identity
    validates :doc_identity, presence: true
    before_validation :set_doc_identity, on: :create
    before_validation :update_doc_identity_slug, on: :update
    before_validation :set_document_type_on_doc_identity
  end

  def_delegators :doc_identity, :slug, :editions_ever_published
  def_delegator :doc_identity, :published?, :linkable?

  def set_doc_identity
    self.doc_identity ||= DocIdentity.new(sluggable_string: self.sluggable_title)
  end

  def update_doc_identity_slug
    self.doc_identity.update_slug_if_possible(self.sluggable_title)
  end

  def set_document_type_on_doc_identity
    self.doc_identity.set_document_type(type) if doc_identity.present?
  end

  module ClassMethods
    def published_as(id)
      begin
        identity = DocIdentity.where(document_type: sti_name).find(id)
        identity && identity.published_edition
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end
  end
end
