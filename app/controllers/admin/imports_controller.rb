class Admin::ImportsController < Admin::BaseController
  before_filter :require_import_permission!
  before_filter :find_import, except: [:index, :new, :create]

  def index
    @imports = Import.order("id desc").includes(:force_publication_attempts, :creator).page(params[:page]).per(10)
  end

  def new
    @import = Import.new
  end

  def create
    csv_file = params[:import].delete(:file)
    @import = Import.create_from_file(current_user,
                                      csv_file,
                                      params[:import][:data_type],
                                      params[:import][:organisation_id])
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
    filename << "-#{annotation_filter}-"
    filename << @import.import_started_at.strftime("%Y-%m-%d-%H%M%S")
    filename << ".csv"
    headers["Content-Type"] ||= 'text/csv'
    headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""

    self.response_body = Enumerator.new do |yielder|
      yielder << (["Errors"] + @import.rows.headers).to_csv
      @import.rows.each_with_index do |row, ix|
        row_number = ix + 2
        errors = @import.import_errors_for_row(row_number)
        case annotation_filter
        when :failed
          next if errors.empty?
        when :succeeded
          next if errors.any?
        end
        error_messages = errors.map do |error|
          error.split("\n", 2).first
        end.join("\n")
        yielder << ([error_messages] + row.fields).to_csv
      end
    end
  end

  def force_publish
    if @import.force_publishable?
      @import.force_publish!
      redirect_to admin_imports_path, notice: "Import #{@import.id} queued for force publishing!"
    else
      redirect_to admin_imports_path, alert: "Import #{@import.id} is not force publishable!"
    end
  end

  def force_publish_log
    @most_recent_attempt = @import.most_recent_force_publication_attempt
    if @most_recent_attempt.nil?
      redirect_to admin_imports_path, notice: "Import #{@import.id} has not been force published yet!"
    end
  end

  def new_document_list; end
  def error_list; end
  def import_log; end

private

  def annotation_filter
    case params[:filter]
    when "failed", "succeeded"
      params[:filter].to_sym
    when nil, ""
      :all
    else
      raise "Illegal filter parameter"
    end
  end

  def find_import
    @import = Import.find(params[:id])
  end
end
