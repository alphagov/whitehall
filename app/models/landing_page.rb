class LandingPage < ApplicationRecord
  after_save :publish_landing_page
end
