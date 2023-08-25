class Admin::FlashNoticeComponent < Admin::FlashMessageComponent
  def component_name
    "success_alert"
  end

  def data_track_action
    "alert-success"
  end
end
