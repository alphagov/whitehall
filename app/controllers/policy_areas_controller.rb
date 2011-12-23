class PolicyAreasController < ApplicationController
  def index
    @policy_areas = PolicyArea.with_published_policies
    @featured_policy_area = FeaturedPolicyAreaChooser.choose_policy_area
  end

  def show
    @policy_area = PolicyArea.find(params[:id])
    @policies = @policy_area.policies.published
    @related_policy_areas = @policy_area.related_policy_areas
    @recently_changed_documents = recently_changed_documents
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
        PolicyArea.unscoped.with_published_policies.randomized.first
      end
    end
  end

  class FeaturedPolicyPresenter < Whitehall::Presenters::Collection
    def initialize(policy_area)
      super(policy_area.featured_policies)
    end
  end

  private

  def recently_changed_documents
    (@policy_area.published_related_documents + @policies).sort_by { |d|
      d.is_a?(Policy) ? d.updated_at : d.published_at
    }.reverse
  end
end