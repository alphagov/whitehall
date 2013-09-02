# == Schema Information
#
# Table name: editions
#
#  id                                          :integer          not null, primary key
#  created_at                                  :datetime
#  updated_at                                  :datetime
#  lock_version                                :integer          default(0)
#  document_id                                 :integer
#  state                                       :string(255)      default("draft"), not null
#  type                                        :string(255)
#  role_appointment_id                         :integer
#  location                                    :string(255)
#  delivered_on                                :datetime
#  opening_on                                  :date
#  closing_on                                  :date
#  major_change_published_at                   :datetime
#  first_published_at                          :datetime
#  publication_date                            :datetime
#  speech_type_id                              :integer
#  stub                                        :boolean          default(FALSE)
#  change_note                                 :text
#  force_published                             :boolean
#  minor_change                                :boolean          default(FALSE)
#  publication_type_id                         :integer
#  related_mainstream_content_url              :string(255)
#  related_mainstream_content_title            :string(255)
#  additional_related_mainstream_content_url   :string(255)
#  additional_related_mainstream_content_title :string(255)
#  alternative_format_provider_id              :integer
#  published_related_publication_count         :integer          default(0), not null
#  public_timestamp                            :datetime
#  primary_mainstream_category_id              :integer
#  scheduled_publication                       :datetime
#  replaces_businesslink                       :boolean          default(FALSE)
#  access_limited                              :boolean          not null
#  published_major_version                     :integer
#  published_minor_version                     :integer
#  operational_field_id                        :integer
#  roll_call_introduction                      :text
#  news_article_type_id                        :integer
#  relevant_to_local_government                :boolean          default(FALSE)
#  person_override                             :string(255)
#  locale                                      :string(255)      default("en"), not null
#  external                                    :boolean          default(FALSE)
#  external_url                                :string(255)
#

class Publication < Publicationesque
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::AlternativeFormatProvider
  include Edition::WorldLocations
  include Edition::StatisticalDataSets
  include Edition::HasHtmlVersion
  include Edition::CanApplyToLocalGovernmentThroughRelatedPolicies
  include Edition::TopicalEvents

  validates :first_published_at, presence: true, if: -> e { e.trying_to_convert_to_draft == true }
  validates :publication_type_id, presence: true
  validate :only_publications_allowed_invalid_data_can_be_awaiting_type
  validate :must_have_attachment, if: :published?

  after_update { |p| p.published_related_policies.each(&:update_published_related_publication_count) }

  def self.subtypes
    PublicationType.all
  end

  def self.by_subtype(subtype)
    where(publication_type_id: subtype.id)
  end

  def self.not_statistics
    where("publication_type_id NOT IN (?)", PublicationType.statistical.map(&:id))
  end

  def self.statistics
    where(publication_type_id: PublicationType.statistical.map(&:id))
  end

  def allows_inline_attachments?
    false
  end

  def allows_attachment_references?
    true
  end

  def can_have_attached_house_of_commons_papers?
    true
  end

  def display_type
    publication_type.singular_name
  end

  def display_type_key
    publication_type.key
  end

  def search_format_types
    super + [Publication.search_format_type] + self.publication_type.search_format_types
  end

  def publication_type
    PublicationType.find_by_id(publication_type_id)
  end

  def publication_type=(publication_type)
    self.publication_type_id = (publication_type && publication_type.id)
    set_access_limited
    self.publication_type
  end

  def publication_type_id=(publication_type_id)
    super
    set_access_limited
    self.publication_type_id
  end

  def national_statistic?
    publication_type == PublicationType::NationalStatistics
  end

  def statistics?
    PublicationType.statistical.include?(publication_type)
  end

  def access_limited_by_default?
    # Without a publication_type we can't correctly work out if we should
    # be access_limited or not.  When we get a publication_type, we'll
    # sort this out.  Happily, abesence of a publication_type invalidates
    # us, so returning nil is ok even though it would break the SQL insert
    if self.publication_type.present?
      self.publication_type.access_limited_by_default?
    else
      nil
    end
  end

  def translatable?
    !non_english_edition?
  end

  def must_have_attachment
    errors.add(:base, "Must have an attachment") unless attachment_present?
  end

  def attachment_present?
    !attachments.empty? || html_version.present?
  end

  private

  def only_publications_allowed_invalid_data_can_be_awaiting_type
    unless self.can_have_some_invalid_data?
      errors.add(:publication_type, 'must be changed') if PublicationType.migration.include?(self.publication_type)
    end
  end
end
