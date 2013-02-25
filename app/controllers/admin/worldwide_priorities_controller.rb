class Admin::WorldwidePrioritiesController < Admin::EditionsController
  before_filter :build_image, only: [:new, :edit]

  def show
    @missing_translations = @edition.missing_translations
  end

  private

  def edition_class
    WorldwidePriority
  end
end
