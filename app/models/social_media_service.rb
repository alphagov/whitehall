class SocialMediaService < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false } # rubocop:disable Rails/UniqueValidationWithoutIndex
end
