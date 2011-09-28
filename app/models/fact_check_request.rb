class FactCheckRequest < ActiveRecord::Base
  belongs_to :edition
  validates_presence_of :edition
  before_create :generate_token
  
  def token=(token)
    # readonly
  end
  
  private
  
  def generate_token
    self[:token] = SecureRandom.base64(15)
  end
end