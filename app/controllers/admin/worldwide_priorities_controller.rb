class Admin::WorldwidePrioritiesController < Admin::EditionsController
  before_filter :build_image, only: [:new, :edit]

  def show
    translated_locales = (@edition.translated_locales - [:en]).map {|l| Locale.new(l)}
    @missing_translations = Locale.non_english - translated_locales
  end

  private

  def edition_class
    WorldwidePriority
  end
end
