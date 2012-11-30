class Admin::FatalityNoticesController < Admin::EditionsController
  prepend_before_filter :require_fatality_handling_permission!, except: :show
  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    FatalityNotice
  end
end
