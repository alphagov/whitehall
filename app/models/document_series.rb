class DocumentSeries < Edition
  include Edition::RelatedPolicies
  include Edition::Topics

  # belongs_to :organisation

  has_many :groups, class_name: 'DocumentSeriesGroup',
                    order: 'document_series_groups.ordering',
                    dependent: :destroy,
                    inverse_of: :document_series

  has_many :documents, through: :groups
  has_many :editions, through: :documents

  before_create :create_default_group

  class ClonesGroupsTrait < Edition::Traits::Trait
    def process_associations_before_save(new_edition)
      new_edition.groups = @edition.groups.map(&:dup)
    end
  end

  add_trait ClonesGroupsTrait

  searchable title:       :title,
             slug:        :slug,
             link:        :search_link,
             content:     :indexable_content,
             description: :summary

  # def published_editions
  #   editions.published.in_reverse_chronological_order
  # end

  # def scheduled_editions
  #   editions.scheduled
  # end

  def search_link
    Whitehall.url_maker.document_series_path(slug)
  end

  def indexable_content
    [
      Govspeak::Document.new(body).to_text,
      groups.map do |group|
        [group.heading, Govspeak::Document.new(group.body).to_text]
      end
    ].flatten.join("\n")
  end

  private

  def create_default_group
    if groups.empty?
      groups << DocumentSeriesGroup.new(DocumentSeriesGroup.default_attributes)
    end
  end
end
