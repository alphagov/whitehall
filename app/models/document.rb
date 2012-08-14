class Document < ActiveRecord::Base
  set_table_name :documents

  extend FriendlyId

  class SlugGeneratorScopedByDocumentType < FriendlyId::SlugGenerator
    def conflicts
      super.with_equivalent_document_type_to(sluggable)
    end
  end
  
  friendly_id :sluggable_string do |config|
    config.use :slugged
    config.slug_generator_class = SlugGeneratorScopedByDocumentType
  end

  after_destroy :destroy_all_editions

  has_many :editions
  has_many :edition_relations, dependent: :destroy

  has_one  :published_edition,
           class_name: 'Edition',
           conditions: { state: 'published' }
  has_one  :unpublished_edition,
           class_name: 'Edition',
           conditions: { state: %w[ draft submitted rejected ] }
  has_many :ever_published_editions,
           class_name: 'Edition',
           conditions: { state: %w[ published archived ] }

  has_many :consultation_responses,
           class_name: 'ConsultationResponse',
           foreign_key: :consultation_document_id,
           dependent: :destroy
  has_one  :published_consultation_response,
           class_name: 'ConsultationResponse',
           foreign_key: :consultation_document_id,
           conditions: { state: 'published' }

  has_one  :latest_edition,
           class_name: 'Edition',
           conditions: %{
             NOT EXISTS (
               SELECT 1 FROM editions e2
               WHERE e2.document_id = editions.document_id
               AND e2.id > editions.id
               AND e2.state <> 'deleted')}

  attr_accessor :sluggable_string

  class Change < Struct.new(:published_at, :note)
    def set_as_first_change
      self.note = "First published." if note.blank?
    end
  end

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  def update_slug_if_possible(new_title)
    update_attributes(sluggable_string: new_title) unless published?
  end

  def published?
    published_edition.present?
  end

  def first_published_date
    published_edition.first_published_date if published?
  end

  def change_history
    editions = ever_published_editions.significant_change.by_published_at

    last = editions.pop
    if last
      last = Change.new(first_published_date, last.change_note)
      last.set_as_first_change
    end

    editions.map { |e| Change.new(e.published_at, e.change_note) }.push(last)
  end

  class << self
    def published
      joins(:published_edition)
    end

    def with_equivalent_document_type_to(edition)
      where(document_type: if announcement_document_types.include?(edition.document_type)
        announcement_document_types
      else
        edition.document_type
      end)
    end

  private    
    def announcement_document_types
      [NewsArticle.document_type, Speech.document_type]
    end

  end

  private

  def destroy_all_editions
    Edition.unscoped.destroy_all(document_id: self.id)
  end


end
