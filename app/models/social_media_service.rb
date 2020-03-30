class SocialMediaService < ApplicationRecord
  validates :name, presence: true, uniqueness: true # rubocop:disable Rails/UniqueValidationWithoutIndex
end
