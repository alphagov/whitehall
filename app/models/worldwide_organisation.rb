class WorldwideOrganisation < Edition
  PRIMARY_ROLES = [AmbassadorRole, HighCommissionerRole, GovernorRole].freeze
  SECONDARY_ROLES = [DeputyHeadOfMissionRole].freeze
  OFFICE_ROLES = [WorldwideOfficeStaffRole].freeze

  include Edition::Searchable

  include Edition::SocialMediaAccounts
  include Edition::Organisations
  include Edition::Roles
  include Edition::WorldLocations

  include Attachable

  has_many :pages, class_name: "WorldwideOrganisationPage", foreign_key: :edition_id, dependent: :destroy, autosave: true

  has_many :offices, class_name: "WorldwideOffice", foreign_key: :edition_id, dependent: :destroy, autosave: true
  belongs_to :main_office, class_name: "WorldwideOffice"

  has_one :default_news_image, class_name: "FeaturedImageData", as: :featured_imageable, inverse_of: :featured_imageable
  accepts_nested_attributes_for :default_news_image, reject_if: :all_blank

  after_commit :republish_dependent_documents

  alias_method :name, :title

  class CloneOfficesTrait < Edition::Traits::Trait
    def process_associations_after_save(new_edition)
      @edition.offices.each do |office|
        new_office = new_edition.offices.build(office.attributes.except("id", "edition_id"))

        new_office.contact = office.contact.dup

        office.contact.contact_numbers.each do |contact_number|
          new_office.contact.contact_numbers << contact_number.dup
        end

        office.services.each do |service|
          new_office.services << service
        end

        new_office.save!

        if @edition.office_shown_on_home_page?(office)
          new_edition.add_office_to_home_page!(new_office)
        end
      end
    end
  end

  add_trait CloneOfficesTrait

  class CloneDefaultImageTrait < Edition::Traits::Trait
    def process_associations_before_save(new_edition)
      return if @edition.default_news_image.blank?

      new_edition.build_default_news_image(@edition.default_news_image.attributes.except("id"))

      @edition.default_news_image.assets.each do |asset|
        new_edition.default_news_image.assets << asset.dup
      end
    end
  end

  add_trait CloneDefaultImageTrait

  class ClonePagesTrait < Edition::Traits::Trait
    def process_associations_before_save(new_edition)
      @edition.pages.each do |page|
        new_page = page.dup

        page.attachments.each do |attachment|
          new_page.attachments << attachment.deep_clone
        end
        new_edition.pages << new_page
      end
    end
  end

  add_trait ClonePagesTrait

  include AnalyticsIdentifierPopulator
  self.analytics_prefix = "WO"

  delegate :alternative_format_contact_email, to: :sponsoring_organisation, allow_nil: true
  def sponsoring_organisation
    lead_organisations.first
  end

  def base_path
    "/world/organisations/#{slug}"
  end

  def display_type_key
    "worldwide_organisation"
  end

  def has_parent_type?
    false
  end

  def destroy_associated(locale)
    [offices.map(&:contact), pages].flatten.each do |association|
      association.remove_translations_for(locale)
    end
  end

  alias_method :original_main_office, :main_office

  extend HomePageList::Container
  has_home_page_list_of :offices
  def home_page_offices
    super - [main_office]
  end

  def home_page_office_contacts
    home_page_offices&.map(&:contact)
  end

  def office_shown_on_home_page?(office)
    super || is_main_office?(office)
  end

  def main_office
    original_main_office || offices.first
  end

  def main_office_contact
    main_office&.contact
  end

  def other_offices
    offices - [main_office]
  end

  def is_main_office?(office)
    main_office == office
  end

  def embassy_offices
    offices.select(&:embassy_office?)
  end

  def office_staff_roles
    roles.occupied.where(type: OFFICE_ROLES.map(&:name))
  end

  def primary_role
    roles.occupied.find_by(type: PRIMARY_ROLES.map(&:name))
  end

  def publishing_api_presenter
    PublishingApi::WorldwideOrganisationPresenter
  end

  def secondary_role
    roles.occupied.find_by(type: SECONDARY_ROLES.map(&:name))
  end

  def corporate_information_page_types
    CorporateInformationPageType.all.reject { |page| page.slug == "about" }
  end

  def previously_published
    false
  end

  def can_have_supporting_organisations?
    false
  end

  def can_set_previously_published?
    false
  end

  def can_be_marked_political?
    false
  end

  def skip_world_location_validation?
    false
  end

  def translatable?
    true
  end

  def requires_taxon?
    false
  end

  def republish_dependent_documents
    documents = NewsArticle
      .joins(:edition_worldwide_organisations)
      .where(edition_worldwide_organisations: { document: })
      .includes(:images)
      .where(images: { id: nil })
      .map(&:document)
      .uniq(&:id)

    documents.each { |d| Whitehall::PublishingApi.republish_document_async(d) }
  end

  def associated_documents
    [offices, offices.map(&:contact), pages].compact.flatten
  end

  def new_content_warning
    "Do not create a worldwide organisation unless you have permission from your managing editor or GOV.UK department lead."
  end
end
