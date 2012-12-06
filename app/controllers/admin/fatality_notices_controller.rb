class Admin::FatalityNoticesController < Admin::EditionsController
  before_filter :require_fatality_handling_permission!, except: :show
  before_filter :build_image, only: [:new, :edit]
  before_filter :build_fatality_notice_casualties, only: [:new, :edit]
  before_filter :destroy_blank_fatality_notice_casualties, only: [:create, :update]

  private

  def edition_class
    FatalityNotice
  end

  def build_fatality_notice_casualties
    unless @edition.fatality_notice_casualties.any?(&:new_record?)
      @edition.fatality_notice_casualties.build
    end
  end

  def destroy_blank_fatality_notice_casualties
    if params[:edition][:fatality_notice_casualties_attributes]
      params[:edition][:fatality_notice_casualties_attributes].each do |index, casualty|
        if casualty[:personal_details].blank?
          casualty[:_destroy] = "1"
        end
      end
    end
  end
end
