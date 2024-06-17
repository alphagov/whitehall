class Admin::FlashAlertComponent < Admin::FlashMessageComponent
  def component_name
    "error_alert"
  end

  def data_track_action
    "alert-danger"
  end
end
