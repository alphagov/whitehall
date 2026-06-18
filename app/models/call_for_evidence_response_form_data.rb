class CallForEvidenceResponseFormData < ApplicationRecord
  include AssetData

  mount_uploader :file, ResponseDocumentUploader, mount_on: :carrierwave_file

  has_one :call_for_evidence_response_form

  validates :file, presence: true

  def replaced?
    false
  end

  def attachable
    return Attachable::Null.new if call_for_evidence_response_form.blank?

    call_for_evidence_response_form
  end

  def attachments
    [call_for_evidence_response_form]
  end

  def auth_bypass_ids
    [call_for_evidence_response_form.call_for_evidence_participation.call_for_evidence.auth_bypass_id]
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
    assets.all? { |asset| asset.filename.include?(filename) } if filename
  end
end
