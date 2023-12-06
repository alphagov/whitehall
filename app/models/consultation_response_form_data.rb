class ConsultationResponseFormData < ApplicationRecord
  mount_uploader :file, ResponseDocumentUploader, mount_on: :carrierwave_file

  has_one :consultation_response_form
  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  validates :file, presence: true

  def auth_bypass_ids
    [consultation_response_form.consultation_participation.consultation.auth_bypass_id]
  end

  def all_asset_variants_uploaded?
    asset_variants = assets.map(&:variant).map(&:to_sym)
    required_variants = [Asset.variants[:original].to_sym]

    return false if (required_variants - asset_variants).any?

    assets_match_updated_image_filename
  end

  def filename
    file.present? && file.file.filename
  end

  def assets_match_updated_image_filename
    assets.reject { |asset| asset.filename.include?(carrierwave_file) }.empty?
  end
end
