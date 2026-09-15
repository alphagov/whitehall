class CallForEvidenceResponseFormData < ApplicationRecord
  include AssetData
  mount_uploader :file, ResponseDocumentUploader, mount_on: :carrierwave_file

  has_one :call_for_evidence_response_form

  validates :file, presence: true

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

  def attachable
    call_for_evidence_response_form&.call_for_evidence_participation&.call_for_evidence || Edition.new
  end

  # A response document is never shared across editions
  # so it can never have been "replaced"
  def replaced?
    false
  end

  def attachments
    [call_for_evidence_response_form || Attachment::Null.new]
  end
end
