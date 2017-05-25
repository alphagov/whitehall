require 'yaml'

class WorldLocationsController < PublicFacingController
  enable_request_formats index: [:json], show: [:atom, :json]
  before_action :load_world_location, only: :show

  def index
    respond_to do |format|
      format.json do
        redirect_to api_world_locations_path(format: :json)
      end
      format.any do
        @world_locations = WorldLocation.all_by_type
        set_meta_description("What is the UK government doing in a country?")
      end
    end
  end

  def show
    recently_updated_source = @world_location.published_editions.with_translations(I18n.locale).in_reverse_chronological_order
    respond_to do |format|
      format.html do
        @recently_updated = recently_updated_source.limit(3)
        publications = Publication.published.in_world_location(@world_location)
        @non_statistics_publications = latest_presenters(publications.not_statistics, translated: true, count: 2)
        @statistics_publications = latest_presenters(publications.statistics, translated: true, count: 2)
        @announcements = latest_presenters(Announcement.published.in_world_location(@world_location), translated: true, count: 2)
        @feature_list = FeatureListPresenter.new(@world_location.feature_list_for_locale(I18n.locale), view_context).limit_to(5)
        @worldwide_organisations = @world_location.worldwide_organisations
        set_meta_description("What the UK government is doing in #{@world_location.name}.")
        set_slimmer_world_locations_header([@world_location])
        set_slimmer_organisations_header(@world_location.worldwide_organisations_with_sponsoring_organisations)
        # Display the "B" variant of this page if:
        # * User is in the "B" bucket
        # * User is requesting a page for which we have hardcoded content
        # * User is requesting the English language version of the page
        ab_test = GovukAbTesting::AbTest.new("WorldwidePublishingTaxonomy", dimension: 45)
        @requested_variant = ab_test.requested_variant(request.headers)
        @requested_variant.configure_response(response)
        if render_b_variant?
          render "worldwide_publishing_taxonomy/show", locals: {
            parent_taxon: parent_taxon,
            b_variant_page_content: b_variant_page_content
          }
        end
      end
      format.json do
        redirect_to api_world_location_path(@world_location, format: :json)
      end
      format.atom do
        @documents = EditionCollectionPresenter.new(recently_updated_source.limit(10), view_context)
      end
    end
  end

  private

  def load_world_location
    @world_location = WorldLocation.with_translations(I18n.locale).find(params[:id])
  end

  def render_b_variant?
    @requested_variant.variant_b? && b_variant_page_content.present? && params[:locale] == "en"
  end

  def parent_taxon
    {
      title: @world_location.title,
      description: "Accessing UK services from #{@world_location.name}, advice for travelling to the UK, and help with trading between the UK and #{@world_location.name}."
    }
  end

  def b_variant_page_content
    @worldwide_publishing_taxonomy_ab_test_content ||= YAML.load_file(Rails.root + "config/worldwide_publishing_taxonomy_ab_test_content.yml")[@world_location.slug]
  end

end
