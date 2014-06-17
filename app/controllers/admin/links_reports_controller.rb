class Admin::LinksReportsController < Admin::BaseController
  before_filter :find_reportable

  def create
    @links_report = LinksReport.queue_for!(@reportable)

    respond_to do |format|
      format.js   { render :show }
      format.html { redirect_to [:admin, @reportable] }
    end
  end

  def show
    @links_report = @reportable.links_reports.find(params[:id])
    respond_to do |format|
      format.js
      format.html { redirect_to [:admin, @reportable] }
    end
  end

private

  def find_reportable
    @reportable = reportable_class.find(reportable_id)
  end

  def reportable_class
    reportable_id_param_name.sub(/_id$/, '').classify.constantize
  rescue NameError
    raise ActiveRecord::RecordNotFound
  end

  def reportable_id
    params[reportable_id_param_name]
  end

  def reportable_id_param_name
    params.keys.find { |k| k =~ /_id$/ }
  end
end
