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

    (required_variants - asset_variants).empty?
  end
end
