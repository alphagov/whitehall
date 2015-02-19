class Admin::GovernmentsController < Admin::BaseController
  before_filter :enforce_create_permissions!, only: [:new, :create]
  before_filter :enforce_edit_permissions!, only: [:edit, :update]

  def index
    @governments = Government.order(start_date: :desc)
  end

  def new
    @government = Government.new
  end

  def edit
    @government = Government.find(params[:id])
  end

  def create
    if Government.create(government_params)
      redirect_to admin_governments_path, notice: 'Created government information'
    else
      render action: 'new'
    end
  end

  def update
    if Government.find(params[:id]).update_attributes(government_params)
      redirect_to admin_governments_path, notice: 'Updated government information'
    else
      render action: 'edit'
    end
  end

private

  def government_params
    params.require(:government).permit(:name, :start_date, :end_date)
  end

  def enforce_create_permissions!
    enforce_permission!(:create, Government)
  end

  def enforce_edit_permissions!
    enforce_permission!(:create, Government.find(params[:id]))
  end
end
