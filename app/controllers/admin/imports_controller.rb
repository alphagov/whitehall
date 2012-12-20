class Admin::ImportsController < Admin::BaseController
  before_filter :require_import_permission!
  before_filter :find_import, only: [:show, :annotated, :run]

  def index
    @imports = Import.order("id desc")
  end

  def new
    @import = Import.new
  end

  def create
    csv_file = params[:import].delete(:file)
    @import = Import.create_from_file(current_user, csv_file, params[:import][:data_type], params[:import][:organisation_id])
    if @import.valid?
      redirect_to admin_import_path(@import)
    else
      render :new
    end
  end

  def run
    @import.enqueue!
    redirect_to admin_import_path(@import)
  end

  def show
  end

  def annotated
    filename = File.basename(@import.original_filename, ".csv")
    filename << "-errors-"
    filename << @import.import_started_at.strftime("%Y-%m-%d-%H%M%S")
    filename << ".csv"
    headers["Content-Type"] ||= 'text/csv'
    headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""

    self.response_body = Enumerator.new do |yielder|
      yielder << (["Errors"] + @import.rows.headers).to_csv
      @import.rows.each_with_index do |row, ix|
        row_number = ix + 2
        errors = @import.import_errors_for_row(row_number).join(", ")
        yielder << ([errors] + row.fields).to_csv
      end
    end
  end

private

  def find_import
    @import = Import.find(params[:id])
  end
end
