class WorldwideOffice < ActiveRecord::Base
  has_one :contact, as: :contactable, dependent: :destroy
  belongs_to :worldwide_organisation
  has_many :worldwide_office_worldwide_services, dependent: :destroy
  has_many :services, through: :worldwide_office_worldwide_services, source: :worldwide_service
  has_one  :access_and_opening_times, as: :accessible, dependent: :destroy
  has_one :default_access_and_opening_times, through: :worldwide_organisation, source: :access_and_opening_times
  validates :worldwide_organisation, :contact, :worldwide_office_type_id, presence: true

  accepts_nested_attributes_for :contact

  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :worldwide_organisation

  extend HomePageList::ContentItem
  is_stored_on_home_page_lists

  # WorldOffice quacks like a Contact
  contact_methods = Contact.column_names +
                    Contact::Translation.column_names +
                    %w(contact_numbers country country_code country_name has_postal_address?) -
                    %w(id contactable_id contactable_type contact_id locale created_at updated_at)

  delegate *contact_methods, to: :contact, allow_nil: true

  delegate :non_english_translated_locales, to: :worldwide_organisation

  def access_and_opening_times_body
    (access_and_opening_times || default_access_and_opening_times).try(:body)
  end

  def worldwide_office_type
    WorldwideOfficeType.find_by_id(worldwide_office_type_id)
  end

  def worldwide_office_type=(worldwide_office_type)
    self.worldwide_office_type_id = worldwide_office_type && worldwide_office_type.id
  end

  def available_in_multiple_languages?
    false
  end
end
