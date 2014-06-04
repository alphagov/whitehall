class Admin::WorldwidePrioritiesController < Admin::EditionsController
  before_filter :build_image, only: [:new, :edit]

private

  def edition_class
    WorldwidePriority
  end
end
