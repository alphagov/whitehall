class Admin::LinkCheckerApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_signature

  def callback
    LinkCheckerApiReport.transaction do
      report = LinkCheckerApiReport.eager_load(:links).lock
        .find_by(batch_id: params.require(:id))
      report.update_from_batch_report(params) if report
    end

    head :no_content
  end

private

  def verify_signature
    return unless webhook_secret_token
    given_signature = request.headers["X-LinkCheckerApi-Signature"]
    return head :bad_request unless given_signature
    body = request.raw_post
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), webhook_secret_token, body)
    head :bad_request unless Rack::Utils.secure_compare(signature, given_signature)
  end

  def webhook_secret_token
    Rails.application.secrets.link_checker_api_secret_token
  end
end
