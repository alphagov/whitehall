class WithdrawHtmlAttachmentTranslationsForWithdrawnEditions < ActiveRecord::Migration[7.0]
  def change
    Edition.where(state: :withdrawn).
    ServiceListeners::PublishingApiPusher
      .new(edition)
      .push(event: "withdraw", options:)
  end
end
