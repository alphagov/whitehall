class CallForEvidenceResponseFormData < ApplicationRecord
  mount_uploader :file, ResponseDocumentUploader, mount_on: :carrierwave_file

  has_one :call_for_evidence_response_form

  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  validates :file, presence: true

  def auth_bypass_ids
    [call_for_evidence_response_form.call_for_evidence_participation.call_for_evidence.auth_bypass_id]
  end

  def asset_uploaded?
    return false unless assets.any? { |asset| asset.variant.to_sym == :original }

    assets_match_updated_image_filename
  end

  def filename
    file.present? && file.file.filename
  end

  def assets_match_updated_image_filename
    assets.all? { |asset| asset.filename.include?(filename) } if filename
  end
end
