class CorporateInformationPage < Edition
  include ::Attachable
  include Searchable

  include Edition::Organisations
  include Edition::WorldwideOrganisations
  delegate :slug, :display_type_key, to: :corporate_information_page_type
  #delegate :alternative_format_contact_email, :acronym, to: :organisation

  #validates :organisation, :body, :type, presence: true
  #validates :corporate_information_page_type_id, uniqueness: {
    #scope: :organisation, message: "already exists for this organisation"
  #}

  validate :only_one_organisation_or_worldwide_organisation
  #include TranslatableModel
  #translates :summary, :body

  #searchable title: :title_prefix_organisation_name,
             #link: :search_link,
             #content: :indexable_content,
             #description: :summary,
             ## NOTE: when we launch world we can change this to belonging_to_live_organisations on its own
             #only: :belonging_to_live_organisations_and_excluding_worldwide_organisations

  #def body_without_markup
    #Govspeak::Document.new(body).to_text
  #end

  #def indexable_content
    #body_without_markup
  #end

  def only_one_organisation_or_worldwide_organisation
    if organisations.size + worldwide_organisations.size > 1
      errors.add(:base, "Only one organisation or worldwide organisation allowed")
    end
  end

  def skip_organisation_validation?
    true
  end

  def organisation
    organisations.first || worldwide_organisations.first
  end

  def search_link
    Whitehall.url_maker.organisation_corporate_information_page_path(organisation, slug)
  end

  def self.for_slug(slug)
    type = CorporateInformationPageType.find(slug)
    find_by_corporate_information_page_type_id(type && type.id)
  end

  def self.for_slug!(slug)
    type = CorporateInformationPageType.find(slug)
    find_by_corporate_information_page_type_id!(type && type.id)
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

  def corporate_information_page_type
    CorporateInformationPageType.find_by_id(corporate_information_page_type_id)
  end

  def corporate_information_page_type=(type)
    self.corporate_information_page_type_id = type && type.id
  end

  def title_prefix_organisation_name
    [organisation.name, title].join(' - ')
  end

  def title
    corporate_information_page_type.title(organisation)
  end

  def self.by_type(*types)
    where(type_id: types.map(&:id))
  end

  def self.by_menu_heading(menu_heading)
    type_ids = CorporateInformationPageType.by_menu_heading(menu_heading).map(&:id)
    where(type_id: type_ids)
  end
end
