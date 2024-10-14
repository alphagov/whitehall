class Admin::LandingPagesController < Admin::BaseController
  before_action :enforce_permissions!
  before_action :load_landing_page, only: %i[edit update confirm_destroy destroy]


  def enforce_permissions!
    # enforce_permission!(:administer, :landing_pages)
  end

  def index
    @landing_pages = LandingPage.all
  end

  def edit; end

  def new
    @landing_page = LandingPage.new
  end

  def create
    @landing_page = LandingPage.new
    if @landing_page.update(landing_page_params)
      redirect_to admin_landing_pages_url(@landing_page), notice: "Landing page created"
    else
      render :new
    end
  end

  def update
    if @landing_page.update(landing_page_params)
      redirect_to admin_landing_pages_url(@landing_page), notice: "Landing page updated"
    else
      render :edit
    end
  end

  def confirm_destroy; end

  def destroy
    @landing_page.destroy!
    redirect_to admin_landing_pages_url(@landing_page), notice: "Landing page deleted"
  end

private

  def load_landing_page
    @landing_page = LandingPage.find(params[:id])
  end

  def landing_page_params
    params.require(:landing_page).permit(
      :base_path,
      :yaml,
    )
  end
end
