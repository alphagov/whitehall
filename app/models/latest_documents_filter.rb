class LatestDocumentsFilter
  attr_reader :subject, :options

  def self.for_subject(subject, options = {})
    case subject
    when TopicalEvent
      TopicalEventFilter.new(subject, options)
    when Organisation
      OrganisationFilter.new(subject, options)
    when WorldLocation
      WorldLocationFilter.new(subject, options)
    end
  end

  def initialize(subject, options = {})
    @subject = subject
    @options = options
  end

  def documents(params = {})
    paginate_rummager_results(search_rummager(params))
  end

private

  def page_number
    options.fetch(:page, 0)
  end

  def page_size
    options.fetch(:per_page, 40)
  end

  def paginate_rummager_results(results)
    Kaminari.paginate_array(results).page(page_number).per(page_size)
  end

  def search_rummager(params)
    SearchRummagerService.new.fetch_related_documents(params)['results']
  end

  class OrganisationFilter < LatestDocumentsFilter
    def documents
      super(
        {
          filter_organisations: subject.slug,
          reject_any_format: 'corporate_information_page'
        }
      )
    end
  end

  class TopicalEventFilter < LatestDocumentsFilter
    def documents
      super(
        {
          filter_topical_events: subject.slug,
          reject_any_content_store_document_type: 'news_article'
        }
      )
    end
  end

  class WorldLocationFilter < LatestDocumentsFilter
    def documents
      super(
        {
          filter_world_locations: subject.slug,
        }
      )
    end
  end
end
