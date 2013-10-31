module Edition::WorldwidePriorities
  extend ActiveSupport::Concern

  include Edition::RelatedDocuments

  included do
    has_many :worldwide_priorities, through: :related_documents, source: :latest_edition, class_name: "WorldwidePriority"
  end

  def published_worldwide_priorities
    worldwide_priorities.published
  end

  # Ensure that when we set priority ids we don't remove other types of edition from the array
  def worldwide_priority_ids=(priority_ids)
    priority_ids = Array.wrap(priority_ids).reject(&:blank?)
    new_priorities = priority_ids.map { |id| WorldwidePriority.find(id).document }
    other_related_documents = self.related_documents.reject { |document| document.latest_edition.is_a?(WorldwidePriority) }

    self.related_documents = other_related_documents + new_priorities
  end

  def can_be_associated_with_worldwide_priorities?
    true
  end
end
