module Edition::WorldwidePriorities
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.worldwide_priorities = @edition.worldwide_priorities
    end
  end

  included do
    has_many :edition_worldwide_priorities, foreign_key: :edition_id, dependent: :destroy
    has_many :worldwide_priorities, through: :edition_worldwide_priorities
    has_many :published_worldwide_priorities,
      through: :edition_worldwide_priorities,
      class_name: "WorldwidePriority",
      conditions: { state: "published" },
      source: :worldwide_priority

    add_trait Trait
  end

  def can_be_associated_with_worldwide_priorities?
    true
  end
end
