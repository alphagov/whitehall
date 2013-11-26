class TopicsController < ClassificationsController
  enable_request_formats show: :atom

  include CacheControlHelper

  def show
    @classification = Topic.find(params[:id])

    respond_to do |format|
      format.html do
        @policies = @classification.published_policies.includes(:translations, :document)
        @consultations = latest_presenters(@classification.published_consultations)
        @publications = latest_presenters(@classification.published_non_statistics_publications)
        @statistics = latest_presenters(@classification.published_statistics_publications)
        @announcements = latest_presenters(@classification.published_announcements)
        @detailed_guides = @classification.published_detailed_guides.includes(:translations, :document).limit(5)
        @related_classifications = @classification.related_classifications
        @featured_editions = decorate_collection(@classification.classification_featurings.includes(:image, edition: [:document, :translations]).limit(5), FeaturedEditionPresenter)

        set_slimmer_organisations_header(@classification.organisations.includes(:translations))
        set_slimmer_page_owner_header(@classification.lead_organisations.includes(:translations).first)
        set_meta_description(@classification.description)

        set_cache_max_age
        expire_on_next_scheduled_publication(@classification.scheduled_editions)

        @recently_changed_documents = @classification.latest(3)
      end
      format.atom do
        @recently_changed_documents = @classification.latest(10)
      end
    end
  end

  private

  def set_cache_max_age
    @cache_max_age = 5.minutes
    set_expiry @cache_max_age
  end
end
