class CorporateInformationPage < Edition
  include ::Attachable
  include Searchable

  has_one :edition_organisation, foreign_key: :edition_id, dependent: :destroy
  has_one :organisation, include: :translations, through: :edition_organisation
  has_one :edition_worldwide_organisation, foreign_key: :edition_id, dependent: :destroy
  has_one :worldwide_organisation, through: :edition_worldwide_organisation

  delegate :slug, :display_type_key, to: :corporate_information_page_type

  add_trait do
    def process_associations_before_save(new_edition)
      if @edition.organisation
        new_edition.organisation = @edition.organisation
      elsif @edition.worldwide_organisation
        new_edition.worldwide_organisation = @edition.worldwide_organisation
      end
    end
  end
  #delegate :alternative_format_contact_email, :acronym, to: :organisation

  #validates :organisation, :body, :type, presence: true
  #validates :corporate_information_page_type_id, uniqueness: {
    #scope: :organisation, message: "already exists for this organisation"
  #}

  validate :only_one_organisation_or_worldwide_organisation
  #include TranslatableModel
  #translates :summary, :body

  def search_title
    title_prefix_organisation_name
  end

  def title_required?
    false
  end

  def update_document_slug
  end

  def ensure_presence_of_document
    self.document ||= Document.new()
  end

  def only_one_organisation_or_worldwide_organisation
    if organisation && worldwide_organisation
      errors.add(:base, "Only one organisation or worldwide organisation allowed")
    end
  end

  def skip_organisation_validation?
    true
  end

  def display_type
    "Corporate information"
  end

  def translatable?
    !non_english_edition?
  end

  def owning_organisation
    organisation || worldwide_organisation
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
    [owning_organisation.name, title].join(' - ')
  end

  def title(locale=:en)
    corporate_information_page_type.title(owning_organisation)
  end

  def self.by_menu_heading(menu_heading)
    type_ids = CorporateInformationPageType.by_menu_heading(menu_heading).map(&:id)
    where(corporate_information_page_type_id: type_ids)
  end

  def summary_required?
    false
  end
end
