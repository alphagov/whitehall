class AboutPagesController < ApplicationController
  def show
    @topical_event = TopicalEvent.find_by_slug!(params[:topical_event_id])
    @about_page = @topical_event.about_page
    raise ActiveRecord::RecordNotFound if @about_page.blank?
  end
end
