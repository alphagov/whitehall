class TopicsController < ApplicationController
  def index
    @topics = Topic.with_published_documents
    @featured_topic = FeaturedTopicChooser.choose_topic
  end

  def show
    @topic = Topic.find(params[:id])
    @policies = @topic.policies.published
    @news_articles = @topic.news_articles.published
    @recently_changed_documents = @topic.published_related_documents.sort_by(&:published_at).reverse
    @featured_policies = FeaturedPolicyPresenter.new(@topic)
  end

  class FeaturedTopicChooser
    class << self
      def choose_topic
        choose_random_featured_topic || choose_random_topic
      end

      def choose_random_featured_topic
        Topic.featured.randomized.first
      end

      def choose_random_topic
        Topic.with_published_documents.randomized.first
      end
    end
  end

  class FeaturedPolicyPresenter < Whitehall::Presenters::Collection
    def initialize(topic)
      super(topic.featured_policies)
    end

    present_object_with do
      def most_recently_updated_related_document
        Document.published.related_to(@record).by_publication_date.first
      end
    end
  end
end