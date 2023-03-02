class Admin::OperationalFieldsController < Admin::BaseController
  before_action :require_fatality_handling_permission!
  layout :get_layout

  def index
    @operational_fields = OperationalField.order(:name)
    render :legacy_index
  end

  def new
    @operational_field = OperationalField.new
  end

  def create
    @operational_field = OperationalField.new(operational_field_params)
    if @operational_field.save
      redirect_to admin_operational_fields_path, notice: %("#{@operational_field.name}" created.)
    else
      render action: "new"
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
      render action: "edit"
    end
  end

private

  def get_layout
    design_system_actions = []
    design_system_actions += %w[index] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def operational_field_params
    params.require(:operational_field).permit(:name, :description)
  end
end
