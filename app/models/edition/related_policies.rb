module Edition::RelatedPolicies
  extend ActiveSupport::Concern

  include Edition::RelatedDocuments

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      edition.policy_content_ids = @edition.policy_content_ids
    end
  end

  included do
    has_many :related_policies, through: :related_documents, source: :latest_edition, class_name: 'Policy'
    has_many :published_related_policies, through: :related_documents, source: :published_edition, class_name: 'Policy'
    has_many :edition_policies, foreign_key: :edition_id
    add_trait Trait
  end

  # Ensure that when we set policy ids we don't remove other types of edition from the array
  def related_policy_ids=(policy_ids)
    policy_ids = Array.wrap(policy_ids).reject(&:blank?)
    new_policies = policy_ids.map {|id| Policy.find(id).document }
    other_related_documents = self.related_documents.reject { |document| document.document_type == Policy.name }
    self.related_documents = other_related_documents + new_policies
  end

  def related_policy_ids
    related_documents.
      find_all {|d| d.document_type == Policy.name }.
      map {|d| d.latest_edition.try(:id) }.compact
  end

  def policy_content_ids
    edition_policies.map(&:policy_content_id)
  end

  def policy_content_ids=(content_ids)
    self.edition_policies = content_ids.map do |content_id|
      EditionPolicy.new(policy_content_id: content_id)
    end
  end

  def policies
    Future::Policy.from_content_ids(policy_content_ids)
  end

  def published_related_policies
    if Whitehall.future_policies_enabled?
      policies
    else
      super
    end
  end

  def related_policies
    if Whitehall.future_policies_enabled?
      policies
    else
      super
    end
  end

  def search_index
    super.merge(policies: policies.map(&:slug))
  end

  def can_be_related_to_policies?
    true
  end
end
