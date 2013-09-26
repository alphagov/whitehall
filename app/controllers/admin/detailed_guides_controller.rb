class Admin::DetailedGuidesController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability

  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    DetailedGuide
  end

  def new_user_need
     @new_user_need ||= @edition.user_needs.to_a.detect(&:new_record?) || UserNeed.new
  end
  helper_method :new_user_need

end
