class Admin::OperationalFieldsController < Admin::BaseController
  before_action :require_fatality_handling_permission!
  layout :get_layout

  def index
    @operational_fields = OperationalField.order(:name)
    render_design_system(:index, :legacy_index, next_release: true)
  end

  def new
    @operational_field = OperationalField.new
    render_design_system(:new, :legacy_new, next_release: true)
  end

  def create
    @operational_field = OperationalField.new(operational_field_params)
    if @operational_field.save
      redirect_to admin_operational_fields_path, notice: %("#{@operational_field.name}" created.)
    else
      render_design_system(:new, :legacy_new, next_release: true)
    end
  end

  def edit
    @operational_field = OperationalField.friendly.find(params[:id])
    render_design_system(:edit, :legacy_edit, next_release: true)
  end

  def update
    @operational_field = OperationalField.friendly.find(params[:id])
    if @operational_field.update(operational_field_params)
      redirect_to admin_operational_fields_path, notice: %("#{@operational_field.name}" saved.)
    else
      render_design_system(:edit, :legacy_edit, next_release: true)
    end
  end

private

  def get_layout
    if preview_design_system?(next_release: true)
      "design_system"
    else
      "admin"
    end
  end

  def operational_field_params
    params.require(:operational_field).permit(:name, :description)
  end
end
