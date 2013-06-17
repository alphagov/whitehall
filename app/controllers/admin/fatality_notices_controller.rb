class Admin::FatalityNoticesController < Admin::EditionsController
  before_filter :require_fatality_handling_permission!, except: :show
  before_filter :build_image, only: [:new, :edit]
  before_filter :build_fatality_notice_casualties, only: [:new, :edit]

  private

  def edition_class
    FatalityNotice
  end

  def build_fatality_notice_casualties
    @edition.fatality_notice_casualties.build unless @edition.fatality_notice_casualties.any?
  end
end
