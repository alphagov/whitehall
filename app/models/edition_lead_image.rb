class EditionLeadImage < ApplicationRecord
  belongs_to :edition
  belongs_to :image

  accepts_nested_attributes_for :edition

  validates :edition, :image, presence: true
  validate :image_is_not_svg, if: -> { image.present? }

private

  def image_is_not_svg
    errors.add(:base, "Lead image can not be an SVG.") if image.svg?
  end
end
