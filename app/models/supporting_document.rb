class SupportingDocument < ActiveRecord::Base
  belongs_to :document

  validates :title, :body, :document, presence: true

  extend FriendlyId
  friendly_id :title, use: :slugged

  def should_generate_new_friendly_id?
    new_record?
  end

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  after_save do
    document.touch
  end
end