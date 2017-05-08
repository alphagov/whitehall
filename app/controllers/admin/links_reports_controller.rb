class Admin::LinksReportsController < Admin::BaseController
  before_action :find_reportable

  def create
    @links_report = LinksReport.queue_for!(@reportable)

    respond_to do |format|
      format.js
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
    @reportable = Edition.find(params[:edition_id])
  end
end
