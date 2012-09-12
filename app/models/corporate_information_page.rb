class CorporateInformationPage < ActiveRecord::Base
  extend Forwardable
  include ::Attachable

  delegate [:title, :slug] => :type
  delegate [:alternative_format_contact_email] => :organisation

  belongs_to :organisation

  attachable :corporate_information_page

  validates :organisation, :body, :type, presence: true
  validates :type_id, uniqueness: {scope: :organisation_id, message: "already exists for this organisation"}

  def self.for_slug(slug)
    type = CorporateInformationPageType.find(slug)
    find_by_type_id!(type.id)
  end

  def type
    CorporateInformationPageType.find_by_id(type_id)
  end

  def type=(type)
    self.type_id = type && type.id
  end

  def to_param
    slug
  end

end