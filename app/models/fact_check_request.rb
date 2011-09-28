class FactCheckRequest < ActiveRecord::Base
  belongs_to :edition
  validates_presence_of :edition, :email_address
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