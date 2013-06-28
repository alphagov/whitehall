class AboutPagesController < ApplicationController
  before_filter :find_subject_and_page, only: [:show]

  private
    def find_subject_and_page
      @subject = TopicalEvent.find_by_slug!(params[:topical_event_id])
      @page = @subject.about_page
      raise ActiveRecord::RecordNotFound if @page.blank?
    end
end
