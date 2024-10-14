class LandingPage < ApplicationRecord
  after_save :publish_landing_page
  after_destroy :unpublish_landing_page

  validates :title, :description, presence: true
  validates :base_path, presence: true, uniqueness: true

private

  def publish_landing_page
    PublishLandingPage.call(self)
  end

  def unpublish_landing_page
    # TODO
  end
end
