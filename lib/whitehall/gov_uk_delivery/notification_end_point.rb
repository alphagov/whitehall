class Whitehall::GovUkDelivery::NotificationEndPoint < Struct.new(:edition, :notification_date)
  def notify!
    raise NotImplementedError 'end points must implement notify!'
  end
end
