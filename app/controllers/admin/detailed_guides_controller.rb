class Admin::DetailedGuidesController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability

  prepend_before_filter :massage_legacy_related_detailed_guide_ids, only: [:create, :update]
  before_filter :build_image, only: [:new, :edit]

private
  def edition_class
    DetailedGuide
  end

  def massage_legacy_related_detailed_guide_ids
    if params.fetch(:edition, {})[:outbound_related_detailed_guide_ids]
      params[:edition][:related_document_ids] = params[:edition].delete(:outbound_related_detailed_guide_ids)
    end
  end
end
