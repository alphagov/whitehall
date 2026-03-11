# frozen_string_literal: true

class Admin::CurrentlyFeaturedTabComponent < ViewComponent::Base
  attr_reader :features, :featurings, :maximum_featured_documents, :read_only

  def initialize(maximum_featured_documents:, features: [], featurings: [], read_only: false)
    @features = features
    @featurings = featurings
    @maximum_featured_documents = maximum_featured_documents
    @read_only = read_only
  end

private

  def featured
    @featured ||= features.presence || featurings
  end

  def live
    @live ||= featured.slice(0, maximum_featured_documents)
  end

  def remaining
    @remaining ||= featured - live
  end

  def table(caption, featured)
    if features.present?
      render Admin::Features::FeaturedDocumentsTableComponent.new(caption:, features: featured, read_only: read_only)
    else
      # Legacy
      render Admin::TopicalEvents::Featurings::FeaturedDocumentsTableComponent.new(caption:, featurings: featured)
    end
  end

  def reorder_path
    if features.present?
      reorder_admin_feature_list_path(features.first.feature_list)
    else
      # legacy
      reorder_admin_topical_event_topical_event_featurings_path(featurings.first.topical_event)
    end
  end
end
