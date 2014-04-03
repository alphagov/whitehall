class DocumentsController < PublicFacingController
  include CacheControlHelper
  include PermissionsChecker
  include PublicDocumentRoutesHelper

  before_filter :redirect_to_canonical_url
  before_filter :find_document, only: [:show]
  before_filter :set_slimmer_headers_for_document, only: [:show]

private

  def build_document_filter
    search_backend.new(cleaned_document_filter_params)
  end

  def cleaned_document_filter_params
    Whitehall::DocumentFilter::CleanedParams.new(params.except(:format, :commit, :_))
  end

  def preview?
    params[:preview]
  end

  def current_user_can_preview?
    preview? && user_signed_in?
  end

  def find_document
    if @document = find_document_or_edition
      if scheduled_document = document_class.scheduled_for_publication_as(params[:id])
        expire_on_next_scheduled_publication([scheduled_document])
      end
    else
      if @document = document_class.scheduled_for_publication_as(params[:id])
        expire_on_next_scheduled_publication([@document])
        render :coming_soon
      elsif @unpublishing = Unpublishing.from_slug(params[:id], document_class)
        if @unpublishing.redirect?
          redirect_to @unpublishing.alternative_url
        else
          # NOTE: We should be returning a 410 here, but because 4XX statuses get clobbered upstream,
          # we are forced to return 200 for now.
          render :unpublished
        end
      else
        expires_in 5.minutes, public: true
        render text: "Not found", status: :not_found
      end
    end
  end

  def find_document_or_edition
    find_document_or_edition_for_preview || find_document_or_edition_for_public
  end

  def find_document_or_edition_for_preview
    return unless current_user_can_preview?
    document = document_class.with_translations(I18n.locale).find(params[:preview])
    if can_preview?(document)
      response.headers['Cache-Control'] = 'no-cache, max-age=0, private'
      document
    end
  end

  def find_document_or_edition_for_public
    document_class.published_as(params[:id], I18n.locale)
  end

  def document_class
    Edition
  end

  # See test/integration/document_locale_param_canonicalization_test
  # for tests for this.  Functional test won't cut it as we can't inject
  # locale: 'en' to query_parameters (it gets swallowed by the .:locale in
  # the route and so ends up in path_parameters).
  def redirect_to_canonical_url
    if request.query_parameters[:locale] == 'en'
      redir_params = request.symbolized_path_parameters.merge(request.query_parameters).symbolize_keys.except(:locale)
      redirect_to canonical_redirect_path(redir_params)
    end
  end
  def canonical_redirect_path(redir_params)
    url_for(redir_params)
  end

  def set_slimmer_headers_for_document
    organisations = @document.importance_ordered_organisations
    organisations += @document.worldwide_organisations if @document.can_be_associated_with_worldwide_organisations?
    set_slimmer_organisations_header(organisations)

    set_slimmer_page_owner_header(@document.lead_organisations.first)

    set_slimmer_world_locations_header(@document.world_locations) if @document.can_be_associated_with_world_locations?
  end
end
