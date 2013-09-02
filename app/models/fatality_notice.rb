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

class FatalityNotice < Announcement
  include Edition::RoleAppointments
  include Edition::FactCheckable

  belongs_to :operational_field

  class CasualtiesTrait < Edition::Traits::Trait
    def process_associations_after_save(new_edition)
      @edition.fatality_notice_casualties.each do |casualty|
        new_edition.fatality_notice_casualties.create(casualty.attributes.except(:id))
      end
    end
  end

  has_many :fatality_notice_casualties, dependent: :destroy

  accepts_nested_attributes_for :fatality_notice_casualties, allow_destroy: true, reject_if: -> attributes { attributes['personal_details'].blank? }

  validates :operational_field, :roll_call_introduction, presence: true

  add_trait CasualtiesTrait

  def can_be_associated_with_worldwide_priorities?
    false
  end

  def has_operational_field?
    true
  end

  def display_type_key
    "fatality_notice"
  end

  def search_index
    super.merge("operational_field" => operational_field.slug)
  end

  def search_format_types
    super + [FatalityNotice.search_format_type]
  end
end
