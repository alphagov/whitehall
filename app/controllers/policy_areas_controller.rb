class PolicyAreasController < ApplicationController
  def index
    @policy_areas = PolicyArea.with_published_documents
    @featured_policy_area = FeaturedPolicyAreaChooser.choose_policy_area
  end

  def show
    @policy_area = PolicyArea.find(params[:id])
    @policies = @policy_area.policies.published
    @news_articles = @policy_area.news_articles.published
    @recently_changed_documents = @policy_area.published_related_documents.sort_by(&:published_at).reverse
    @featured_policies = FeaturedPolicyPresenter.new(@policy_area)
  end

  class FeaturedPolicyAreaChooser
    class << self
      def choose_policy_area
        choose_random_featured_policy_area || choose_random_policy_area
      end

      def choose_random_featured_policy_area
        PolicyArea.unscoped.featured.randomized.first
      end

      def choose_random_policy_area
        PolicyArea.unscoped.with_published_documents.randomized.first
      end
    end
  end

  class FeaturedPolicyPresenter < Whitehall::Presenters::Collection
    def initialize(policy_area)
      super(policy_area.featured_policies)
    end

    present_object_with do
      def most_recently_updated_related_document
        Document.published.related_to(@record).by_publication_date.first
      end
    end
  end
end