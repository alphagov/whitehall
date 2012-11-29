class Admin::OperationalFieldsController < Admin::BaseController
  def index
    @operational_fields = OperationalField.order(:name)
  end

  def new
    @operational_field = OperationalField.new
  end

  def create
    @operational_field = OperationalField.new(params[:operational_field])
    if @operational_field.save
      redirect_to admin_operational_fields_path, notice: %{"#{@operational_field.name}" created.}
    else
      render action: "new"
    end
  end

  def edit
    @operational_field = OperationalField.find(params[:id])
  end

  def update
    @operational_field = OperationalField.find(params[:id])
    if @operational_field.update_attributes(params[:operational_field])
      redirect_to admin_operational_fields_path, notice: %{"#{@operational_field.name}" saved.}
    else
      render action: "edit"
    end
  end
end
