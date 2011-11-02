class Attachment < ActiveRecord::Base
  mount_uploader :file, AttachmentUploader, mount_on: :carrierwave_file
  has_many :document_attachments
  has_many :documents, through: :document_attachments

  delegate :url, to: :file

  validates :file, presence: true

  def filename
    url && File.basename(url)
  end
end