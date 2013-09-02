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

class CaseStudy < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut
  include Edition::HasDocumentSeries
  include Edition::WorldLocations
  include Edition::WorldwideOrganisations
  include Edition::WorldwidePriorities

  validates :first_published_at, presence: true, if: -> e { e.trying_to_convert_to_draft == true }

  def display_type_key
    "case_study"
  end

  def search_format_types
    super + [CaseStudy.search_format_type]
  end

  def translatable?
    !non_english_edition?
  end
end
