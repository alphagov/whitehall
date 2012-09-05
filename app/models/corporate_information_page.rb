class CorporateInformationPage < ActiveRecord::Base
  extend Forwardable

  delegate [:title, :slug] => :type
  belongs_to :organisation
  has_many :corporate_information_page_attachments
  has_many :attachments, through: :corporate_information_page_attachments

  validates :organisation, :body, :type, presence: true

  def type
    CorporateInformationPageType.find_by_id(type_id)
  end

  def type=(type)
    self.type_id = type && type.id
  end

end