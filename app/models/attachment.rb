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
      self.number_of_pages = calculate_number_of_pages
    end
  end

  class PageReceiver
    attr_reader :number_of_pages
    def page_count(count)
      @number_of_pages = count
    end
  end

  def calculate_number_of_pages
    receiver = PageReceiver.new
    PDF::Reader.file(file.path, receiver, pages: false)
    receiver.number_of_pages
  rescue
    nil
  end
end