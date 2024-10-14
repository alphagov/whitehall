class LandingPage < ApplicationRecord
  after_save :publish_landing_page

private

  def publish_landing_page
    PublishLandingPage.call(self)
  end
end
