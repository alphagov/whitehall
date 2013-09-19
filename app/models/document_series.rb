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

  # TODO
  # searchable title: :name,
  #            link: :search_link,
  #            content: :indexable_content,
  #            description: :summary,
  #            slug: :slug

  # def published_editions
  #   editions.published.in_reverse_chronological_order
  # end

  # def scheduled_editions
  #   editions.scheduled
  # end

  # def search_link
  #   Whitehall.url_maker.organisation_document_series_path(organisation, slug)
  # end

  # def indexable_content
  #   [
  #     Govspeak::Document.new(description).to_text,
  #     groups.map do |group|
  #       [group.heading, Govspeak::Document.new(group.body).to_text]
  #     end
  #   ].flatten.join("\n")
  # end

  # def destroyable?
  #   published_editions.empty?
  # end

  private

  def create_default_group
    if groups.empty?
      groups << DocumentSeriesGroup.new(DocumentSeriesGroup.default_attributes)
    end
  end
end
