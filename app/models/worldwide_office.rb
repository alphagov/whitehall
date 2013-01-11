class WorldwideOffice < ActiveRecord::Base
  include Whitehall::Models::SocialMedia

  validates_with SafeHtmlValidator
  validates :name, :summary, :description, presence: true

  extend FriendlyId
  friendly_id

  def display_name
    self.name
  end
end
