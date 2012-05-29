class Admin::SpeechesController < Admin::EditionsController
  before_filter :set_type, only: [:update]
  before_filter :build_image, only: [:new, :edit]

  private

  def set_type
    @edition.type = edition_class.to_s
  end

  def edition_class
    if params[:document].present? && params[:document][:type].present?
      params[:document][:type].constantize
    else
      Speech
    end
  end

  def find_edition
    @edition = Speech.find(params[:id])
  end
end
