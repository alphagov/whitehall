class FactCheckRequest < ActiveRecord::Base
  belongs_to :document
  validates_presence_of :document, :email_address
  validates :email_address, email_format: {allow_blank: true}

  before_create :generate_token

  scope :completed, where('comments IS NOT NULL')

  def token=(token)
    # readonly
  end

  def to_param
    token
  end

  private

  def generate_token
    self[:token] = SecureRandom.hex(15)
  end
end