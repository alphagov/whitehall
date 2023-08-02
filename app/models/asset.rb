class Asset < ApplicationRecord
  belongs_to :assetable, polymorphic: true

  validates :asset_manager_id, presence: true
  validates :assetable, presence: true
  validates :variant, presence: true

  enum variant: {
    original: "original".freeze,
    thumbnail: "thumbnail".freeze,
    s960: "s960".freeze,
    s712: "s712".freeze,
    s630: "s630".freeze,
    s465: "s465".freeze,
    s300: "s300".freeze,
    s216: "s216".freeze,
  }
end
