class Admin::LinkCheckerApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :verify_webhook

  def callback
    LinkCheckerApiReport.transaction do
      report = LinkCheckerApiReport.eager_load(:links).lock
        .find_by(batch_id: params.require(:id))
      report.update_from_batch_report(params) if report
    end

    head :no_content
  end

private

  def verify_webhook
    # TODO
  end
end
