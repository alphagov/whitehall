class Admin::ImportsController < Admin::BaseController

  def index
    @imports = Import.all
  end

  def new
    @import = Import.new
  end

  def create
    csv_file = params[:import].delete(:file)
    @import = Import.create_from_file(current_user, csv_file, params[:import][:data_type])
    if @import.valid?
      @import.enqueue!
      redirect_to admin_import_path(@import)
    else
      render :new
    end
  end

  def show
    @import = Import.find(params[:id])
  end
end
