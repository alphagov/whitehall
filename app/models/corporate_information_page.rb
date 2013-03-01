class CorporateInformationPage < ActiveRecord::Base
  include ::Attachable
  include Searchable
  include Rails.application.routes.url_helpers

  delegate :slug, to: :type
  delegate :alternative_format_contact_email, :acronym, to: :organisation

  belongs_to :organisation, polymorphic: true

  attachable :corporate_information_page

  validates :organisation, :body, :type, presence: true
  validates :type_id, uniqueness: { scope: [:organisation_id, :organisation_type], message: "already exists for this organisation" }

  include TranslatableModel
  translates :summary, :body

  searchable title: :title_prefix_organisation_name,
             link: :search_link,
             content: :indexable_content

  def body_without_markup
    Govspeak::Document.new(body).to_text
  end

  def indexable_content
    body_without_markup
  end

  def search_link
    organisation_corporate_information_page_path(organisation, slug)
  end

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

  def title_prefix_organisation_name
    [organisation.name, title].join(' - ')
  end

  def title
    type.title(organisation)
  end

  def self.by_type(*types)
    where(type_id: types.map(&:id))
  end

  def self.by_menu_heading(menu_heading)
    type_ids = CorporateInformationPageType.by_menu_heading(menu_heading).map(&:id)
    where(type_id: type_ids)
  end
end
