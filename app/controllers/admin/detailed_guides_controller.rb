class Admin::DetailedGuidesController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability

  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    DetailedGuide
  end

  def clean_edition_parameters
    super
    params[:edition].delete_if { |k, v| ["user_need_ids", "user_needs_attributes"].include?(k.to_s) }
  end
end
