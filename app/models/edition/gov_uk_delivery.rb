module Edition::GovUkDelivery
  extend ActiveSupport::Concern

  included do
    # TODO: Gov Deliver notifications to be handled by service object
    set_callback(:publish, :after) { Whitehall::GovUkDelivery::Notifier.new(self).edition_published! }
  end
end
