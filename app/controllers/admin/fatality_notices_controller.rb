class Admin::FatalityNoticesController < Admin::EditionsController
  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    FatalityNotice
  end
end
