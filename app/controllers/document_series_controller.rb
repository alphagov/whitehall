class DocumentSeriesController < PublicFacingController
  include CacheControlHelper
  before_filter :load_organisation

  def index
    redirect_to publications_path(departments: [@organisation])
  end

  def show
    @document_series = @organisation.document_series.find(params[:id])
    @groups = visible_groups
    @most_recent_change = most_recent_change
    set_slimmer_organisations_header([@document_series.organisation])
    set_slimmer_page_owner_header(@document_series.organisation)
    expire_on_next_scheduled_publication(@document_series.scheduled_editions)
    set_meta_description(@document_series.summary)
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end

  def visible_groups
    items = []
    @document_series.groups.visible.each do |group|
      items << group
      editions = group.published_editions.includes(:document, :translations)
      items << decorate_collection(editions, PublicationesquePresenter)
    end
    Hash[*items]
  end

  def most_recent_change
    if @groups.present?
      @document_series.published_editions.first.public_timestamp
    end
  end
end
