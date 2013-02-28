class CorporateInformationPage < ActiveRecord::Base
  extend Forwardable
  include ::Attachable

  delegate [:slug] => :type
  delegate [:alternative_format_contact_email] => :organisation

  belongs_to :organisation, polymorphic: true

  attachable :corporate_information_page

  validates :organisation, :body, :type, presence: true
  validates :type_id, uniqueness: { scope: [:organisation_id, :organisation_type], message: "already exists for this organisation" }

  def self.for_slug(slug)
    type = CorporateInformationPageType.find(slug)
    find_by_type_id(type && type.id)
  end

  def self.for_slug!(slug)
    type = CorporateInformationPageType.find(slug)
    find_by_type_id!(type && type.id)
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

  def title
    type.title(organisation)
  end

  def self.by_menu_heading(menu_heading)
    type_ids = CorporateInformationPageType.by_menu_heading(menu_heading).map(&:id)
    where(type_id: type_ids)
  end

  def available_in_multiple_languages?
    false
  end
end
