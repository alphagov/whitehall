class Admin::AboutPagesController < Admin::BaseController
  before_filter :find_topical_event
  before_filter :find_page, except: [:new, :create]

  helper_method :model_name, :human_friendly_model_name

  def new
    @about_page = AboutPage.new
  end

  def create
    @about_page = @topical_event.build_about_page(about_page_params)
    if @about_page.save
      redirect_to admin_topical_event_about_pages_path, notice: 'About page created'
    else
      render action: 'new'
    end
  end

  def update
    if @about_page.update_attributes(about_page_params)
      redirect_to admin_topical_event_about_pages_path, notice: 'About page saved'
    else
      render action: 'edit'
    end
  end

  def show
    @about_page = @topical_event.about_page
  end

  def model_name
    TopicalEvent.name.underscore
  end

  def human_friendly_model_name
    model_name.humanize
  end

private
  def find_topical_event
    @topical_event = TopicalEvent.find(params[:topical_event_id])
  end

  def find_page
    @about_page = @topical_event.about_page
  end

  def about_page_params
    params.require(:about_page).permit(:body, :name, :summary, :read_more_link_text)
  end
end
