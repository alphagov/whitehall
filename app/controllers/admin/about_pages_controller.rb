class Admin::AboutPagesController < Admin::BaseController
  before_filter :build_page, only: [:new]
  before_filter :find_subject

  helper_method :model_name, :human_friendly_model_name

  def create
    @page = AboutPage.new(params[:about_page])
    @page.subject = @subject
    if @page.save
      redirect_to send("admin_#{model_name}_about_pages_path"), notice: "About page created"
    else
      render action: 'new'
    end
  end

  def show
    @page = @subject.about_page
  end

  def model_name
    TopicalEvent.name.underscore
  end

  def human_friendly_model_name
    model_name.humanize
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

    def build_page
      @page = AboutPage.new
    end
end
