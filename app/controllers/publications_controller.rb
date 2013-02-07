class PublicationsController < DocumentsController
  class MysqlPublicationesqueDecorator < SimpleDelegator
    def documents
      PublicationesquePresenter.decorate(__getobj__.documents)
    end
  end

  class ElasticSearchPublicationesqueDecorator < SimpleDelegator
    def search
      __getobj__.publication_search.results
    end
    def documents
      PublicationesquePresenter.decorate(__getobj__.publication_search.results)
    end
    def count
      search.results.count
    end
    def current_page
      search.current_page
    end
    def num_pages
      search.total_pages
    end
    def total_count
      search.total_entries
    end
    def last_page?
      search.last_page?
    end
    def first_page?
      search.first_page?
    end
  end

  def index
    params[:page] ||= 1
    params[:direction] ||= "before"

    clean_malformed_params_array(:topics)
    clean_malformed_params_array(:departments)

    expire_on_next_scheduled_publication(scheduled_publications)

    @filter = build_filter

    respond_to do |format|
      format.html
      format.json do
        render json: PublicationFilterJsonPresenter.new(@filter)
      end
      format.atom do
        @publications = @filter.documents.sort_by(&:public_timestamp).reverse
      end
    end
  end

  def show
    @related_policies = @document.statistics? ? [] : @document.published_related_policies
    set_slimmer_organisations_header(@document.organisations)
  end

private

  def build_filter
    if params[:use_elastic_search].present?
      document_filter = Whitehall::DocumentFilter::ElasticSearch.new(params)
      ElasticSearchPublicationesqueDecorator.new(document_filter)
    else
      document_filter = Whitehall::DocumentFilter::Mysql.new(all_publications, params)
      MysqlPublicationesqueDecorator.new(document_filter)
    end
  end

  def all_publications
    Publicationesque.published.includes(:document, :organisations, :attachments, :translations, response: :attachments)
  end

  def scheduled_publications
    unfiltered = Publicationesque.scheduled.order("scheduled_publication asc")
    Whitehall::DocumentFilter::Mysql.new(unfiltered, params.except(:direction)).documents
  end

  def document_class
    Publication
  end
end
