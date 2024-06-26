class RoleAppointment < ApplicationRecord
  include DateValidation
  include HasContentId
  include PublishesToPublishingApi
  include ReshuffleMode

  date_attributes(:started_at, :ended_at)

  CURRENT_CONDITION = { ended_at: nil }.freeze

  has_many :edition_role_appointments
  has_many :editions, through: :edition_role_appointments

  # All this nonsense is because of all the intermediary associations
  has_many :consultations,
           -> { where("editions.type" => "Consultation") },
           through: :edition_role_appointments,
           source: :edition
  has_many :publications,
           -> { where("editions.type" => "Publication") },
           through: :edition_role_appointments,
           source: :edition
  has_many :news_articles,
           -> { where("editions.type" => "NewsArticle") },
           through: :edition_role_appointments,
           source: :edition

  # Speeches do not need the above nonsense because they have a singualar
  # association in the `editions` table
  has_many :speeches

  belongs_to :role
  belongs_to :person
  has_many :organisations, through: :role
  has_many :worldwide_organisations, through: :role

  delegate :slug, to: :person
  delegate :name, to: :role, prefix: true
  delegate :ministerial?, to: :role

  class Validator < ActiveModel::Validator
    def validate(record)
      if record.make_current
        if record.before_any?
          record.errors.add(:started_at, "should not be before any existing appointment")
        end
      elsif record.role && record.overlaps_any?
        record.errors.add(:base, "should not overlap with any existing appointments")
      end
      if record.ended_at && (record.ended_at < record.started_at)
        record.errors.add(:ends_at, "should not be before appointment starts")
      end
      %i[started_at ended_at].each do |attribute|
        if record.send(attribute) && (record.send(attribute) > Time.zone.now)
          record.errors.add(attribute, "should not be in the future")
        end
      end
    end
  end

  validates :role_id, :person_id, :started_at, presence: true
  validates_with Validator, if: -> { started_at.present? }

  scope :for_role, ->(role) { where(role_id: role.id) }
  scope :for_person, ->(person) { where(person_id: person.id) }
  scope :excluding_ids, ->(*ids) { where("id NOT IN (?)", ids) }
  scope :current, -> { where(CURRENT_CONDITION) }
  scope :for_ministerial_roles, -> { includes(role: :organisations).merge(Role.ministerial).references(:roles) }
  scope :alphabetical_by_person, -> { includes(:person).order("people.surname", "people.forename") }
  scope :ascending_start_date, -> { order("started_at DESC") }
  scope :historic, -> { where.not(CURRENT_CONDITION) }

  after_create :set_ordering
  after_create :make_other_current_appointments_non_current
  before_destroy :prevent_destruction_unless_destroyable

  after_save :republish_ministerial_pages_to_publishing_api, if: :ministerial?
  after_save :republish_associated_editions_to_publishing_api, :republish_organisation_to_publishing_api, :republish_worldwide_organisations_to_publishing_api, :republish_prime_ministers_index_page_to_publishing_api, :republish_role_to_publishing_api
  after_destroy :republish_associated_editions_to_publishing_api, :republish_organisation_to_publishing_api, :republish_worldwide_organisations_to_publishing_api, :republish_prime_ministers_index_page_to_publishing_api, :republish_role_to_publishing_api

  def republish_associated_editions_to_publishing_api
    role.edition_roles.each do |edition_role|
      PublishingApiDocumentRepublishingWorker.perform_async(edition_role.edition.document_id)
    end
  end

  def republish_organisation_to_publishing_api
    organisations.each do |organisation|
      Whitehall::PublishingApi.republish_async(organisation)
    end
  end

  def republish_worldwide_organisations_to_publishing_api
    worldwide_organisations.each do |worldwide_organisation|
      Whitehall::PublishingApi.republish_async(worldwide_organisation)
    end
  end

  def republish_prime_ministers_index_page_to_publishing_api
    PresentPageToPublishingApiWorker.perform_async("PublishingApi::HistoricalAccountsIndexPresenter") unless current? || role.slug != "prime-minister" || has_historical_account?
  end

  def republish_role_to_publishing_api
    Whitehall::PublishingApi.republish_async(role)
  end

  def self.between(start_time, end_time)
    where(started_at: start_time..end_time)
  end

  attr_accessor :make_current

  def current?
    started_at.present? && ended_at.nil?
  end

  def type
    if new_record?
      "new"
    elsif current?
      "current"
    else
      "previous"
    end
  end

  def destroyable?
    persisted? && speeches.empty?
  end

  def before_any?
    other_appointments_for_same_role.where("started_at >= ?", started_at).exists?
  end

  def overlaps_any?
    overlapping_appointments.exists?
  end

  def overlapping_appointments
    if ended_at.nil?
      other_appointments_for_same_role.where(
        "((:my_started_at BETWEEN started_at AND ended_at) AND :my_started_at != ended_at)" \
                "OR (started_at >= :my_started_at) " \
                "OR (ended_at IS NULL)",
        my_started_at: started_at,
      )
    else
      other_appointments_for_same_role.where(
        "((:my_started_at BETWEEN started_at AND ended_at) AND :my_started_at != ended_at)" \
                                                     "OR ((started_at BETWEEN :my_started_at AND :my_ended_at) AND started_at != :my_ended_at)" \
                                                     "OR (:my_ended_at > started_at AND ended_at IS NULL)",
        my_started_at: started_at,
        my_ended_at: ended_at,
      )
    end
  end

  def other_appointments_for_same_role
    if persisted?
      self.class.for_role(role).excluding_ids(id)
    else
      self.class.for_role(role)
    end
  end

  def current_at(date)
    return true if date.nil?
    return false if date < started_at

    ended_at.nil? || date <= ended_at
  end

  delegate :historical_account, to: :person

  def has_historical_account?
    historical_account.present?
  end

  def publishing_api_presenter
    PublishingApi::RoleAppointmentPresenter
  end

private

  def make_other_current_appointments_non_current
    return unless make_current

    other_appointments = other_appointments_for_same_role.current
    other_appointments.each do |oa|
      oa.ended_at = started_at
      oa.save!
    end
  end

  def set_ordering
    update_column(:ordering, person.role_appointments.count)
  end

  def prevent_destruction_unless_destroyable
    throw :abort unless destroyable?
  end
end
