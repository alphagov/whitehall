module Edition::GovUkDelivery
  extend ActiveSupport::Concern

  included do
    set_callback(:publish, :after) { Whitehall::GovUkDelivery::Notifier.new(self).edition_published! }
  end
end
