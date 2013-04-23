class GovUkDeliveryNotificationJob < Struct.new(:notifier)
  def perform
    response = Whitehall.govuk_delivery_client.notify(notifier.tags, notifier.title, notifier.email_body)
  rescue GdsApi::HTTPErrorResponse => exception
    raise unless exception.code == 400
  end
end
