class Admin::FlashAlertComponent < Admin::FlashMessageComponent
  def component_name
    "error_alert"
  end

  def data_attributes
    {
      module: "ga4-auto-tracker",
      "ga4-auto": {
        event_name: "flash_message",
        text: message,
        action: "error",
      }.to_json,
    }
  end
end
