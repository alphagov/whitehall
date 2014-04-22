module Edition::RelatedPolicies
  extend ActiveSupport::Concern

  include Edition::RelatedDocuments

  included do
    has_many :related_policies, through: :related_documents, source: :latest_edition, class_name: 'Policy'
    has_many :published_related_policies, through: :related_documents, source: :published_edition, class_name: 'Policy'
  end

  # Ensure that when we set policy ids we don't remove other types of edition from the array
  def related_policy_ids=(policy_ids)
    policy_ids = Array.wrap(policy_ids).reject(&:blank?)
    new_policies = policy_ids.map {|id| Policy.find(id).document }
    other_related_documents = self.related_documents.reject { |document| document.latest_edition.is_a?(Policy) }
    self.related_documents = other_related_documents + new_policies
  end

  def can_be_related_to_policies?
    true
  end
end
