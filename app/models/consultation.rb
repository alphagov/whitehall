class Consultation < Publicationesque
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::AlternativeFormatProvider

  validates :opening_on, presence: true
  validates :closing_on, presence: true
  validate :closing_on_must_be_after_opening_on
  validate :must_have_consultation_as_publication_type

  has_one :consultation_participation, foreign_key: :edition_id, dependent: :destroy

  after_update { |p| p.published_related_policies.each(&:update_published_related_publication_count) }

  accepts_nested_attributes_for :consultation_participation, reject_if: :all_blank_or_empty_hashes
  accepts_nested_attributes_for :response, reject_if: :all_blank_or_empty_hashes

  add_trait do
    def process_associations_after_save(edition)
      if @edition.consultation_participation.present?
        attributes = @edition.consultation_participation.attributes.except("id", "edition_id")
        edition.create_consultation_participation(attributes)
      end

      if @edition.response.present?
        response_attributes = @edition.response.attributes.except('edition_id')
        new_response = edition.create_response(response_attributes)
        @edition.response.attachments.each do |attachment|
          new_response.consultation_response_attachments.create(attachment: Attachment.create(attachment.attributes))
        end
      end
    end
  end

  def initialize(*args)
    super
    self.publication_type_id = PublicationType::Consultation.id
  end

  def not_yet_open?
    opening_on > Date.today
  end

  def open?
    !closed? && opening_on <= Date.today
  end

  def closed?
    closing_on < Date.today
  end

  def published_consultation_response
    response if response && response.published?
  end

  def response_published?
    closed? && published_consultation_response
  end

  def response_published_on
    response.published_on_or_default
  end

  def first_public_at
    opening_on.to_datetime
  end

  def make_public_at(date)
  end

  def first_published_date
    opening_on.to_date
  end

  def allows_attachment_references?
    true
  end

  def has_consultation_participation?
    consultation_participation.present?
  end

  def display_type
    if response_published?
      "Consultation outcome"
    elsif closed?
      "Closed consultation"
    elsif open?
      "Open consultation"
    else
      "Consultation"
    end
  end

  private

  def closing_on_must_be_after_opening_on
    if closing_on && opening_on && closing_on.to_date <= opening_on.to_date
      errors.add :closing_on,  "must be after the opening on date"
    end
  end

  def must_have_consultation_as_publication_type
    unless publication_type_id == PublicationType::Consultation.id
      errors.add :publication_type_id, "must be set to consultation"
    end
  end

  def all_blank_or_empty_hashes(attributes)
    hash_with_blank_values?(attributes)
  end

  def hash_with_blank_values?(hash)
    hash.values.inject(true) do |result, value|
      result && (value.is_a?(Hash) ? hash_with_blank_values?(value) : value.blank?)
    end
  end

  class << self
    def closed
      where 'closing_on < :today', today: Date.today
    end

    def open
      where 'closing_on >= :today AND opening_on <= :today', today: Date.today
    end

    def upcoming
      where 'opening_on > :today', today: Date.today
    end
  end
end
