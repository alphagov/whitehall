class Admin::DetailedGuidesController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability

  prepend_before_filter :massage_legacy_related_detailed_guide_ids, only: [:create, :update]
  before_filter :build_image, only: [:new, :edit]

private
  def edition_class
    DetailedGuide
  end

  # TODO: This can be removed once the code has been successfully deployed
  def massage_legacy_related_detailed_guide_ids
    if params.fetch(:edition, {})[:outbound_related_detailed_guide_ids]
      detailed_guides = Document.find(params[:edition].delete(:outbound_related_detailed_guide_ids)).map(&:latest_edition)
      params[:edition][:related_detailed_guide_ids] = detailed_guides.map(&:id)
    end
  end
end
