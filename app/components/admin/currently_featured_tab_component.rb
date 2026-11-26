# frozen_string_literal: true

class Admin::CurrentlyFeaturedTabComponent < ViewComponent::Base
  attr_reader :features, :maximum_featured_documents, :read_only

  def initialize(maximum_featured_documents:, features: [], read_only: false)
    @features = features
    @maximum_featured_documents = maximum_featured_documents
    @read_only = read_only
  end

private

  def live
    @live ||= features.slice(0, maximum_featured_documents)
  end

  def remaining
    @remaining ||= features - live
  end

  def table(caption, featured)
    render Admin::Features::FeaturedDocumentsTableComponent.new(caption:, features: featured, read_only: read_only)
  end

  def reorder_path
    reorder_admin_feature_list_path(features.first.feature_list)
  end
end
