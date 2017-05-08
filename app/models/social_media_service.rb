class SocialMediaService < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
