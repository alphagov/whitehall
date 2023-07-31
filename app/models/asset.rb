class Asset < ApplicationRecord
  belongs_to :assetable, polymorphic: true

  validates :asset_manager_id, presence: true
  validates :assetable, presence: true
  validates :variant, presence: true

  enum variant: { original: "original".freeze, thumbnail: "thumbnail".freeze }
end
