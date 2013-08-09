class AttachmentData < ActiveRecord::Base
  mount_uploader :file, AttachmentUploader, mount_on: :carrierwave_file

  delegate :url, :path, to: :file, allow_nil: true

  before_save :update_file_attributes

  validates :file, presence: true
  validate :file_is_not_empty

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

  def txt?
    file_extension == "txt"
  end

  def indexable?
    AttachmentUploader::INDEXABLE_TYPES.include?(file_extension)
  end

  def text_file_path
    path.gsub(/\.[^\.]+$/, ".txt")
  end

  def text_file_exists?
    File.exist?(text_file_path)
  end

  def read_extracted_text
    if text_file_exists?
      File.open(text_file_path).read
    end
  end

  def extracted_text
    if indexable? && File.exist?(path)
      if Whitehall.extract_text_feature?
        read_extracted_text
      end
    end
  end

  def virus_status
    if File.exists?(infected_path)
      :infected
    elsif File.exists?(clean_path)
      :clean
    else
      :pending
    end
  end

  # Newly instantiated AttachmentData will report the file path as in the incoming
  # directory because of the way Whitehall::QuarantinedFileStorage works. This method
  # will return the expected clean path, regardless of what path reports.
  def clean_path
    path.gsub(Whitehall.incoming_uploads_root, Whitehall.clean_uploads_root)
  end

  def infected_path
    clean_path.gsub(Whitehall.clean_uploads_root, Whitehall.infected_uploads_root)
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
    PDFINFO_SERVICE.count_pages(path)
  rescue
    nil
  end

  def file_is_not_empty
    errors.add(:file, "is an empty file") if file.present? && file.file.size.to_i == 0
  end
end
