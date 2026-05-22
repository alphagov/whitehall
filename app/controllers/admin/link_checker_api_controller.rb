class Admin::LinkCheckerApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_signature

  def callback
    GovukStatsd.time("link-checking-debug.link-checker-callback") do
      logger.info("[link-checking-debug][batch_#{params[:id]}]: Updating link report")
      LinkCheckerApiReport.transaction do
        report = LinkCheckerApiReport.eager_load(:links).lock
          .find_by(batch_id: params.require(:id))
        report.mark_report_as_completed(params) if report
      end
      logger.info("[link-checking-debug][batch_#{params[:id]}]: Done updating link report")
    end
    head :no_content
  end

private

  def verify_signature
    return head :service_unavailable unless webhook_configured?
    return head :bad_request unless signature_present?

    reject_unauthorized unless signature_valid?
  end

  def webhook_configured?
    webhook_secret_token.present?
  end

  def signature_present?
    request_signature.present?
  end

  def signature_valid?
    expected = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), webhook_secret_token, request.raw_post)
    Rack::Utils.secure_compare(expected, request_signature)
  end

  def reject_unauthorized
    # Opt out of gds-sso's Warden intercept_401, which would otherwise turn
    # this response into a redirect to /auth/gds.
    request.env["warden"].custom_failure!
    head :unauthorized
  end

  def request_signature
    request.headers["X-LinkCheckerApi-Signature"]
  end

  def webhook_secret_token
    Rails.application.credentials.link_checker_api_secret_token
  end
end
