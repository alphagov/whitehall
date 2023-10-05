class Asset < ApplicationRecord
  belongs_to :assetable, polymorphic: true

  validates :asset_manager_id, presence: true
  validates :assetable, presence: true
  validates :variant, presence: true
  validates :filename, presence: true

  validate :unique_variant_for_each_assetable

  def unique_variant_for_each_assetable
    return unless assetable

    if Asset.where(assetable_id:, assetable_type:, variant:).where.not(id:).exists?
      errors.add(:variant, "#{variant} already exists for the assetable #{assetable_type} of id #{assetable_id}")
    end
  end

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
