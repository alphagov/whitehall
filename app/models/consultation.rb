class Consultation < Publicationesque
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::AlternativeFormatProvider

  validates :opening_on, presence: true, unless: ->(consultation) { consultation.can_have_some_invalid_data? }
  validates :closing_on, presence: true, unless: ->(consultation) { consultation.can_have_some_invalid_data? }
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
    opening_on.nil? || (opening_on > Date.today)
  end

  def open?
    opening_on.present? && !closed? && opening_on <= Date.today
  end

  def closed?
    closing_on.nil? || (closing_on < Date.today)
  end

  def published_consultation_response
    response if response && response.published?
  end

  def response_published?
    closed? && published_consultation_response.present?
  end

  def response_published_on
    response.published_on_or_default
  end

  def first_public_at
    opening_on.to_datetime unless opening_on.nil?
  end

  def make_public_at(date)
  end

  def first_published_date
    opening_on.to_date unless opening_on.nil?
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

  def display_type_key
    if response_published?
      "consultation_outcome"
    elsif closed?
      "closed_consultation"
    elsif open?
      "open_consultation"
    else
      "consultation"
    end
  end

  def can_apply_to_local_government?
    true
  end

  def search_format_types
    consultation_type =
      if response_published?
        'consultation-outcome'
      elsif closed?
        'consultation-closed'
      elsif open?
        'consultation-open'
      end

    types = super + ['publicationesque-consultation', Consultation.search_format_type]
    types << consultation_type if consultation_type
    types
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

  class << self
    def closed
      where 'closing_on < :today', today: Date.today
    end

    def closed_since(earliest_closing_date)
      closed.where 'closing_on >= :earliest_closing_date', earliest_closing_date: earliest_closing_date.to_date
    end

    def open
      where 'closing_on >= :today AND opening_on <= :today', today: Date.today
    end

    def upcoming
      where 'opening_on > :today', today: Date.today
    end

    def responded
      joins(response: :attachments)
    end
  end
end
