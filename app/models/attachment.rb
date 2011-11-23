class Attachment < ActiveRecord::Base
  mount_uploader :file, AttachmentUploader, mount_on: :carrierwave_file
  has_many :document_attachments
  has_many :documents, through: :document_attachments

  delegate :url, to: :file

  validates :file, presence: true

  before_save :update_file_attributes

  def filename
    url && File.basename(url)
  end

  def destroy_if_unassociated
    self.destroy if document_attachments.empty?
  end

  private

  def update_file_attributes
    if carrierwave_file.present? && carrierwave_file_changed?
      self.content_type = file.file.content_type
      self.file_size = file.file.size
    end
  end
end