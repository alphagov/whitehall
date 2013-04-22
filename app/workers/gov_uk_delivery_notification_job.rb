class GovUkDeliveryNotificationJob < Struct.new(:notifier)
  def perform
    response = Whitehall.govuk_delivery_client.notify(notifier.govuk_delivery_tags, notifier.title, notifier.govuk_delivery_email_body)
  rescue GdsApi::HTTPErrorResponse => exception
    raise unless exception.code == 400
  end
end
