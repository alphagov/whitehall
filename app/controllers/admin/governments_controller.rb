class Admin::GovernmentsController < Admin::BaseController
  def index
    @governments = Government.order(end_date: :desc)
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
end
