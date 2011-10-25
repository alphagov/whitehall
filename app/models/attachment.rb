class Attachment < ActiveRecord::Base
  mount_uploader :file, AttachmentUploader, mount_on: :carrierwave_file
  has_many :documents

  delegate :url, to: :file

  validates :file, presence: true

  def filename
    url && File.basename(url)
  end
end