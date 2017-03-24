# This is a temporary implementation to support the migration of
# whitehall emailing from govuk_delivery to email_alert_api.
# This has been implemented as a worker while the govuk_delivery
# code has been left inline.
# Once we have switched over to using email-alert-api for sending
# emails and retired govuk_delivery this code should be moved to the
# controller action and the govuk_delivery code deleted.
require 'gds_api/helpers'

class EmailAlertApiSignupWorker < WorkerBase
  class UnexpectedTopicID < StandardError; end
  include GdsApi::Helpers

  sidekiq_options queue: "email_alert_api_signup"

  def perform(topic_id, feed_url)
    parser = UrlToSubscriberListCriteria.new(feed_url)
    criteria = parser.convert.merge('gov_delivery_id' => topic_id)
    response = email_alert_api.find_or_create_subscriber_list(criteria)
    unless response['subscriber_list']['gov_delivery_id'] == topic_id
      raise UnexpectedTopicID.new("#{response['subscriber_list']['gov_delivery_id']} <> #{topic_id}")
    end
  end
end
