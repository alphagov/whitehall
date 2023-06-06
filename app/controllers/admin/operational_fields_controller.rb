class Admin::OperationalFieldsController < Admin::BaseController
  before_action :require_fatality_handling_permission!
  layout "design_system"

  def index
    @operational_fields = OperationalField.order(:name)
  end

  def new
    @operational_field = OperationalField.new
  end

  def create
    @operational_field = OperationalField.new(operational_field_params)
    if @operational_field.save
      redirect_to admin_operational_fields_path, notice: %("#{@operational_field.name}" created.)
    else
      render :new
    end
  end

  def edit
    @operational_field = OperationalField.friendly.find(params[:id])
  end

  def update
    @operational_field = OperationalField.friendly.find(params[:id])
    if @operational_field.update(operational_field_params)
      redirect_to admin_operational_fields_path, notice: %("#{@operational_field.name}" saved.)
    else
      render :edit
    end
  end

private

  def operational_field_params
    params.require(:operational_field).permit(:name, :description)
  end
end
