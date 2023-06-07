class Admin::TakePartPagesController < Admin::BaseController
  before_action :enforce_permissions!
  layout :get_layout

  def enforce_permissions!
    enforce_permission!(:administer, :get_involved_section)
  end

  def index
    @take_part_pages = TakePartPage.in_order
    render_design_system(:index, :legacy_index)
  end

  def new
    @take_part_page = TakePartPage.new
    render_design_system("new", "legacy_new")
  end

  def create
    @take_part_page = TakePartPage.new(take_part_page_params)
    if @take_part_page.save
      redirect_to [:admin, TakePartPage], notice: %(Take part page "#{@take_part_page.title}" created!)
    else
      render_design_system("new", "legacy_new")
    end
  end

  def edit
    @take_part_page = TakePartPage.friendly.find(params[:id])
    render_design_system("edit", "legacy_edit")
  end

  def update
    @take_part_page = TakePartPage.friendly.find(params[:id])
    if @take_part_page.update(take_part_page_params)
      redirect_to [:admin, TakePartPage], notice: %(Take part page "#{@take_part_page.title}" updated!)
    else
      render :edit
    end
  end

  def confirm_destroy
    @take_part_page = TakePartPage.friendly.find(params[:id])
  end

  def destroy
    @take_part_page = TakePartPage.friendly.find(params[:id])
    @take_part_page.destroy!
    redirect_to [:admin, TakePartPage], notice: %(Take part page "#{@take_part_page.title}" deleted!)
  end

  def update_order
    @take_part_pages = TakePartPage.in_order
  end

  def reorder
    new_ordering = (params.permit!.to_h[:ordering] || []).sort_by { |_id, ordering| ordering.to_i }.map(&:first)
    TakePartPage.reorder!(new_ordering)
    redirect_to admin_take_part_pages_path, notice: "Take part pages reordered!"
  end

private

  def get_layout
    design_system_actions = []
    design_system_actions += %w[new create index edit update confirm_destroy update_order] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def take_part_page_params
    params.require(:take_part_page).permit(
      :title, :summary, :body, :image, :image_alt_text, :image_cache
    )
  end
end
