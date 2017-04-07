class Admin::LinkCheckReportsController < Admin::BaseController
  before_filter :find_reportable

  def create
    @report = LinkCheckerApiService.check_links(
      @reportable,
      admin_link_checker_api_callback_url
    )

    respond_to do |format|
      format.js
      format.html { redirect_to [:admin, @reportable] }
    end
  end

  def show
    @report = LinkCheckerApiReport.find(params[:id])
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
