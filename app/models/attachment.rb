class Attachment < ActiveRecord::Base
  mount_uploader :file, AttachmentUploader
  has_many :documents

  validates :file, presence: true
end