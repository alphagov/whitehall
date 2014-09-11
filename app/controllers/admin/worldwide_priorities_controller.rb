class Admin::WorldwidePrioritiesController < Admin::EditionsController

  private

  def edition_class
    WorldwidePriority
  end

  def document_can_be_previously_published
    false
  end
end
