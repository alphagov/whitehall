class Admin::FlashMessageComponent < ViewComponent::Base
  def initialize(message:, html_safe: false)
    @html_safe = html_safe
    @message = message
  end

  def message
    if @html_safe
      @message.html_safe
    else
      @message
    end
  end

  def data_attributes
    {
      module: "ga4-auto-tracker",
      "ga4-auto": {
        event_name: "flash_notice",
        text: message,
        action: "success_alerts",
      }.to_json,
    }
  end
end
