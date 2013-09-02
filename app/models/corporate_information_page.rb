# == Schema Information
#
# Table name: corporate_information_pages
#
#  id                :integer          not null, primary key
#  lock_version      :integer
#  organisation_id   :integer
#  type_id           :integer
#  created_at        :datetime
#  updated_at        :datetime
#  organisation_type :string(255)
#

class CorporateInformationPage < ActiveRecord::Base
  include ::Attachable
  include Searchable

  delegate :slug, :display_type_key, to: :type
  delegate :alternative_format_contact_email, :acronym, to: :organisation

  belongs_to :organisation, polymorphic: true

  attachable :corporate_information_page

  validates :organisation, :body, :type, presence: true
  validates :type_id, uniqueness: { scope: [:organisation_id, :organisation_type], message: "already exists for this organisation" }

  include TranslatableModel
  translates :summary, :body

  searchable title: :title_prefix_organisation_name,
             link: :search_link,
             content: :indexable_content,
             description: :summary,
             # NOTE: when we launch world we can change this to belonging_to_live_organisations on it's own
             only: :belonging_to_live_organisations_and_excluding_worldwide_organisations

  def body_without_markup
    Govspeak::Document.new(body).to_text
  end

  def indexable_content
    body_without_markup
  end

  def search_link
    Whitehall.url_maker.organisation_corporate_information_page_path(organisation, slug)
  end

  def self.for_slug(slug)
    type = CorporateInformationPageType.find(slug)
    find_by_type_id(type && type.id)
  end

  def self.for_slug!(slug)
    type = CorporateInformationPageType.find(slug)
    find_by_type_id!(type && type.id)
  end

  def self.belonging_to_live_organisations_and_excluding_worldwide_organisations
    belonging_to_live_organisations.excluding_worldwide_organisations
  end

  def self.belonging_to_live_organisations
    joins("LEFT OUTER JOIN organisations ON
      corporate_information_pages.organisation_id = organisations.id AND
      corporate_information_pages.organisation_type = 'Organisation'").
    where("(#{Organisation.arel_table[:id].eq(nil).to_sql} OR #{Organisation.arel_table[:govuk_status].eq('live').to_sql})")
  end

  def self.excluding_worldwide_organisations
    where(CorporateInformationPage.arel_table[:organisation_type].not_eq('WorldwideOrganisation'))
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
