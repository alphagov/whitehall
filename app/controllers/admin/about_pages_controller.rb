class Admin::AboutPagesController < Admin::BaseController
  before_filter :find_subject, only: [:show]

  helper_method :model_name

  def show
  end

  def model_name
    TopicalEvent.name.underscore
  end

  private
    def find_subject
      @subject = TopicalEvent.find(params[:topical_event_id])
    end

    def find_page
      @about_page = @topical_event.about_page
    end

    def build_page
    end

    def show_path
      send("admin_#{model_name}_about_pages_path")
    end
end
