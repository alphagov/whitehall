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

# @abstract
class Publicationesque < Edition
  include Edition::RelatedPolicies
  include Edition::HasDocumentSeries
  include Edition::Topics
  include Edition::WorldwidePriorities
  include Edition::GovUkDelivery
  include ::Attachable

  attachable :edition

  def self.sti_names
    ([self] + descendants).map { |model| model.sti_name }
  end

  def presenter
    PublicationesquePresenter
  end

  protected

  def search_format_types
    super + [Publicationesque.search_format_type]
  end

  def hash_with_blank_values?(hash)
    hash.values.reduce(true) do |result, value|
      result && (value.is_a?(Hash) ? hash_with_blank_values?(value) : value.blank?)
    end
  end

  def all_blank_or_empty_hashes(attributes)
    hash_with_blank_values?(attributes)
  end
end

require_relative 'publication'
require_relative 'consultation'
