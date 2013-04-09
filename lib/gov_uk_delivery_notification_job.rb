class GovUkDeliveryNotificationJob < Struct.new(:id)

  def perform
    Whitehall.govuk_delivery_client.notify(edition.govuk_delivery_tags, edition.title, edition.govuk_delivery_email_body)
  end

  def edition
    @edition ||= Edition.find(id)
  end
end
