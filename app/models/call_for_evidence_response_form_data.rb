class CallForEvidenceResponseFormData < ApplicationRecord
  include AssetData

  mount_uploader :file, ResponseDocumentUploader, mount_on: :carrierwave_file

  has_one :call_for_evidence_response_form

  validates :file, presence: true

  delegate :auth_bypass_id, to: :attachable

  def attachable
    call_for_evidence_response_form || Attachable::Null.new
  end

  def attachments
    [call_for_evidence_response_form || Attachment::Null.new]
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
