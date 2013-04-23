class Admin::TakePartPagesController < Admin::BaseController
  before_filter :enforce_permissions!
  def enforce_permissions!
    enforce_permission!(:administer, :get_involved_section)
  end

  def index
    @take_part_pages = TakePartPage.in_order
  end

  def new
    @take_part_page = TakePartPage.new
  end

  def create
    @take_part_page = TakePartPage.new(params[:take_part_page])
    if @take_part_page.save
      redirect_to [:admin, TakePartPage], notice: %Q{Take part page "#{@take_part_page.title}" created!}
    else
      render :new
    end
  end

  def edit
    @take_part_page = TakePartPage.find(params[:id])
  end

  def update
    @take_part_page = TakePartPage.find(params[:id])
    if @take_part_page.update_attributes(params[:take_part_page])
      redirect_to [:admin, TakePartPage], notice: %Q{Take part page "#{@take_part_page.title}" updated!}
    else
      render :edit
    end
  end

  def destroy
    @take_part_page = TakePartPage.find(params[:id])
    @take_part_page.destroy
    redirect_to [:admin, TakePartPage], notice: %Q{Take part page "#{@take_part_page.title}" deleted!}
  end

  def reorder
    new_ordering = (params[:ordering] || []).sort_by {|id, ordering| ordering.to_i}.map(&:first)
    TakePartPage.reorder!(new_ordering)
    redirect_to admin_take_part_pages_path, notice: 'Take part pages reordered!'
  end
end
