class AttachmentData < ActiveRecord::Base
  mount_uploader :file, AttachmentUploader, mount_on: :carrierwave_file

  delegate :url, to: :file, allow_nil: true

  before_save :update_file_attributes

  validates :file, presence: true

  attr_accessor :to_replace_id
  belongs_to :replaced_by, class_name: 'AttachmentData'
  validate :cant_be_replaced_by_self
  after_save :handle_to_replace_id

  def filename
    url && File.basename(url)
  end

  def file_extension
    File.extname(url).gsub(/\./, "") if url.present?
  end

  def pdf?
    content_type == AttachmentUploader::PDF_CONTENT_TYPE
  end

  def indexable?
    AttachmentUploader::INDEXABLE_TYPES.include?(file_extension)
  end

  def extracted_text
    path = file.path
    if indexable? && File.exist?(path)
      if Whitehall.extract_text_feature?
        extract_text(path)
      end
    end
  end

  def extract_text(path)
    output = `tika -t #{path}`
    result = $?.success?
    output if result
  end

  def update_file_attributes
    if carrierwave_file.present? && carrierwave_file_changed?
      self.content_type = file.file.content_type
      self.file_size = file.file.size
      if pdf?
        self.number_of_pages = calculate_number_of_pages
      end
    end
  end

  def replace_with!(replacement)
    # NOTE: we're doing this manually because carrierwave is setup such
    # that production instances aren't valid because the storage location
    # for files is not where carrierwave thinks they are (because of
    # virus-checking).
    self.replaced_by = replacement
    cant_be_replaced_by_self
    raise ActiveRecord::RecordInvalid, self if self.errors.any?
    self.update_column(:replaced_by_id, replacement.id)
    AttachmentData.where(replaced_by_id: self.id).each do |ad|
      ad.replace_with!(replacement)
    end
  end

  def cant_be_replaced_by_self
    return if replaced_by.nil?
    errors.add(:base, "can't be replaced by itself") if replaced_by == self
  end

  def handle_to_replace_id
    return if to_replace_id.nil?
    AttachmentData.find(to_replace_id).replace_with!(self)
  end

  def calculate_number_of_pages
    PDFINFO_SERVICE.count_pages(file.path)
  rescue
    nil
  end
end
