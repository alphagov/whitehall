# frozen_string_literal: true

require "test_helper"

class Admin::CurrentlyFeaturedTabComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers
  include Admin::EditionRoutesHelper
  include Admin::OrganisationHelper

  setup do
    @maximum_featured_documents = 5
  end

  test "renders h2 so that screen readers have context for which tab they're in" do
    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_selector "h2", text: "Currently featured"
  end

  test "informs the user how many documents they can feature" do
    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_selector ".gem-c-inset-text", text: "A maximum of 5 documents will be featured on GOV.UK."
  end

  test "renders link to the reorder features page if more than 1 feature_list item" do
    feature_list = build_stubbed(:feature_list)
    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features: build_list(:feature, 2, feature_list:),
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_selector ".govuk-link[href='#{reorder_admin_feature_list_path(feature_list)}']", text: "Reorder documents"
  end

  test "does not render link to the reorder page if less than 2 feature_list items" do
    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features: [build(:feature)],
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_selector ".govuk-link", text: "Reorder documents", count: 0
  end

  test "makes one call to the features FeaturedDocumentsTableComponent when features count is <= to maximum_featured_documents" do
    feature_list = build_stubbed(:feature_list)
    features = build_list(:feature, @maximum_featured_documents, feature_list:)
    table_component = Admin::Features::FeaturedDocumentsTableComponent.new(caption: "caption", features: [])

    Admin::Features::FeaturedDocumentsTableComponent
    .expects(:new)
    .with(features:, caption: "#{features.count} featured documents live on GOV.UK")
    .once
    .returns(table_component)

    table_component
    .expects(:render)
    .returns("")

    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features:,
                    maximum_featured_documents: @maximum_featured_documents,
                  ))
  end

  test "makes two calls to the features FeaturedDocumentsTableComponent when features count is greater than maximum_featured_documents" do
    feature_list = build_stubbed(:feature_list)
    live_features = build_list(:feature, @maximum_featured_documents, feature_list:)
    remaining_features = build(:feature, feature_list:)
    table_component1 = Admin::Features::FeaturedDocumentsTableComponent.new(caption: "caption1", features: [])
    table_component2 = Admin::Features::FeaturedDocumentsTableComponent.new(caption: "caption2", features: [])

    Admin::Features::FeaturedDocumentsTableComponent
    .expects(:new)
    .with(features: live_features, caption: "#{live_features.count} featured documents live on GOV.UK")
    .once
    .returns(table_component1)

    table_component1
    .expects(:render)
    .once
    .returns("")

    Admin::Features::FeaturedDocumentsTableComponent
    .expects(:new)
    .with(features: [remaining_features], caption: "1 remaining featured document")
    .once
    .returns(table_component2)

    table_component2
    .expects(:render)
    .once
    .returns("")

    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    features: live_features + [remaining_features],
                    maximum_featured_documents: @maximum_featured_documents,
                  ))
  end

  test "renders link to the reorder featurings page if more than 1 feature_list item" do
    topical_event = build_stubbed(:topical_event)
    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    featurings: build_stubbed_list(:topical_event_featuring, 2, topical_event:),
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_selector ".govuk-link[href='#{reorder_admin_topical_event_topical_event_featurings_path(topical_event)}']", text: "Reorder documents"
  end

  test "does not render link to the reorder page if less than 2 featurings" do
    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    featurings: [build_stubbed(:topical_event_featuring)],
                    maximum_featured_documents: @maximum_featured_documents,
                  ))

    assert_selector ".govuk-link", text: "Reorder documents", count: 0
  end

  test "makes one call to the featurings FeaturedDocumentsTableComponent when featurings count is <= to maximum_featured_documents" do
    topical_event = build_stubbed(:topical_event)
    featurings = build_stubbed_list(:topical_event_featuring, @maximum_featured_documents, topical_event:)
    table_component = Admin::TopicalEvents::Featurings::FeaturedDocumentsTableComponent.new(caption: "caption", featurings: [])

    Admin::TopicalEvents::Featurings::FeaturedDocumentsTableComponent
    .expects(:new)
    .with(featurings:, caption: "#{featurings.count} featured documents live on GOV.UK")
    .once
    .returns(table_component)

    table_component
    .expects(:render)
    .returns("")

    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    featurings:,
                    maximum_featured_documents: @maximum_featured_documents,
                  ))
  end

  test "makes two calls to the featurings FeaturedDocumentsTableComponent when featurings count is greater than maximum_featured_documents" do
    topical_event = build_stubbed(:topical_event)
    live_featurings = build_stubbed_list(:topical_event_featuring, @maximum_featured_documents, topical_event:)
    remaining_featurings = build_stubbed(:topical_event_featuring, topical_event:)
    table_component1 = Admin::TopicalEvents::Featurings::FeaturedDocumentsTableComponent.new(caption: "caption1", featurings: [])
    table_component2 = Admin::TopicalEvents::Featurings::FeaturedDocumentsTableComponent.new(caption: "caption2", featurings: [])

    Admin::TopicalEvents::Featurings::FeaturedDocumentsTableComponent
    .expects(:new)
    .with(featurings: live_featurings, caption: "#{live_featurings.count} featured documents live on GOV.UK")
    .once
    .returns(table_component1)

    table_component1
    .expects(:render)
    .once
    .returns("")

    Admin::TopicalEvents::Featurings::FeaturedDocumentsTableComponent
    .expects(:new)
    .with(featurings: [remaining_featurings], caption: "1 remaining featured document")
    .once
    .returns(table_component2)

    table_component2
    .expects(:render)
    .once
    .returns("")

    render_inline(Admin::CurrentlyFeaturedTabComponent.new(
                    featurings: live_featurings + [remaining_featurings],
                    maximum_featured_documents: @maximum_featured_documents,
                  ))
  end
end
