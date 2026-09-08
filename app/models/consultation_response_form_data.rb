class ConsultationResponseFormData < ApplicationRecord
  include AssetData
  mount_uploader :file, ResponseDocumentUploader, mount_on: :carrierwave_file

  has_one :consultation_response_form

  validates :file, presence: true

  def all_asset_variants_uploaded?
    super && assets_match_updated_image_filename
  end

  def attachable
    consultation_response_form&.consultation_participation&.consultation || Edition.new
  end

  # A response document is never shared across editions
  # so it can never have been "replaced"
  def replaced?
    false
  end

  def attachments
    [consultation_response_form || Attachment::Null.new]
  end
end
