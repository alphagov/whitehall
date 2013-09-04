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

class DetailedGuide < Edition
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::Topics
  include ::Attachable
  include Edition::AlternativeFormatProvider
  include Edition::FactCheckable
  include Edition::HasMainstreamCategories
  include Edition::HasDocumentSeries

  delegate :section, :subsection, :subsubsection, to: :primary_mainstream_category, allow_nil: true

  attachable :edition

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      edition.outbound_related_documents = @edition.outbound_related_documents
    end
  end

  has_many :outbound_edition_relations, foreign_key: :edition_id, dependent: :destroy, class_name: 'EditionRelation'
  has_many :outbound_related_documents, through: :outbound_edition_relations, source: :document
  has_many :latest_outbound_related_detailed_guides, through: :outbound_related_documents, source: :latest_edition, class_name: 'DetailedGuide'
  has_many :published_outbound_related_detailed_guides, through: :outbound_related_documents, source: :published_edition, class_name: 'DetailedGuide'

  has_many :inbound_edition_relations, through: :document, source: :edition_relations
  has_many :inbound_related_editions, through: :inbound_edition_relations, source: :edition
  has_many :inbound_related_documents, through: :inbound_related_editions, source: :document
  has_many :latest_inbound_related_detailed_guides, through: :inbound_related_documents, source: :latest_edition, class_name: 'DetailedGuide'
  has_many :published_inbound_related_detailed_guides, through: :inbound_related_documents, source: :published_edition, class_name: 'DetailedGuide'

  add_trait Trait

  validate :related_mainstream_content_valid?
  validate :additional_related_mainstream_content_valid?

  class HeadingHierarchyValidator < ActiveModel::Validator
    include GovspeakHelper
    def validate(record)
      govspeak_header_hierarchy(record.body)
    rescue OrphanedHeadingError => e
      record.errors.add(:body, "must have a level-2 heading (h2 - ##) before level-3 heading (h3 - ###): '#{e.heading}'")
    end
  end

  validates_with HeadingHierarchyValidator

  def rummager_index
    :detailed_guides
  end

  def related_detailed_guides
    (latest_outbound_related_detailed_guides + latest_inbound_related_detailed_guides).uniq
  end

  def published_related_detailed_guides
    (published_outbound_related_detailed_guides + published_inbound_related_detailed_guides).uniq
  end

  def can_be_related_to_mainstream_content?
    true
  end

  def has_related_mainstream_content?
    related_mainstream_content_url.present?
  end

  def has_additional_related_mainstream_content?
    additional_related_mainstream_content_url.present?
  end

  def display_type_key
    "detailed_guidance"
  end

  def search_format_types
    super + [DetailedGuide.search_format_type]
  end
  def self.search_format_type
    'detailed-guidance'
  end

  private

  def related_mainstream_content_valid?
    if related_mainstream_content_url.present? && related_mainstream_content_title.blank?
      errors.add(:related_mainstream_content_title, "cannot be blank if a related URL is given")
    end
  end

  def additional_related_mainstream_content_valid?
    if additional_related_mainstream_content_url.present? && additional_related_mainstream_content_title.blank?
      errors.add(:additional_related_mainstream_content_title, "cannot be blank if an additional related URL is given")
    end
  end

  class << self
    def format_name
      'detailed guidance'
    end
  end
end
