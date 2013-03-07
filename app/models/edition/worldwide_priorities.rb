module Edition::WorldwidePriorities
  extend ActiveSupport::Concern

  include Edition::RelatedDocuments

  included do
    has_many :worldwide_priorities, through: :related_documents, source: :latest_edition
    has_many :published_worldwide_priorities,
      through: :related_documents,
      class_name: "WorldwidePriority",
      conditions: { state: "published" },
      source: :published_edition
  end

  def can_be_associated_with_worldwide_priorities?
    true
  end
end
