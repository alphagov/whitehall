class Asset < ApplicationRecord
  belongs_to :attachment_data

  validates :asset_manager_id, presence: true
  validates :attachment_data, presence: true
  validates :variant, presence: true

  enum variant: { original: "original".freeze, thumbnail: "thumbnail".freeze }
end
