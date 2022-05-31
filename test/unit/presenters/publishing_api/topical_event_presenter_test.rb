require "test_helper"

class PublishingApi::TopicalEventPresenterTest < ActiveSupport::TestCase
  test "presents a valid topical_event content item" do
    topical_event = create(
      :topical_event,
      :active,
      name: "Humans going to Mars",
      description: "A topical event description with [a link](http://www.gov.uk)",
    )
    create(:topical_event_about_page, topical_event: topical_event, read_more_link_text: "Read more about this event")
    public_path = "/government/topical-events/humans-going-to-mars"

    feature = create(:classification_featuring, classification: topical_event, ordering: 1)
    offsite_feature = create(:offsite_classification_featuring, classification: topical_event, ordering: 0)

    social_media_service = create(:social_media_service, name: "Facebook")
    social_media_account = create(:social_media_account, social_media_service: social_media_service)
    topical_event.social_media_accounts = [social_media_account]

    expected_hash = {
      base_path: public_path,
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      schema_name: "topical_event",
      document_type: "topical_event",
      title: "Humans going to Mars",
      description: topical_event.summary,
      locale: "en",
      routes: [
        {
          path: public_path,
          type: "exact",
        },
      ],
      update_type: "major",
      redirects: [],
      public_updated_at: topical_event.updated_at,
      details: {
        about_page_link_text: topical_event.about_page.read_more_link_text,
        body: Whitehall::GovspeakRenderer.new.govspeak_to_html(topical_event.description),
        start_date: topical_event.start_date.rfc3339,
        end_date: topical_event.end_date.rfc3339,
        ordered_featured_documents: [
          {
            title: offsite_feature.title,
            href: offsite_feature.url,
            image: {
              url: offsite_feature.image.file.url(:s465),
              alt_text: offsite_feature.alt_text,
            },
            summary: offsite_feature.summary,
          },
          {
            title: feature.title,
            href: feature.url,
            image: {
              url: feature.image.file.url(:s465),
              alt_text: feature.alt_text,
            },
            summary: feature.summary,
          },
        ],
        social_media_links: [
          {
            href: social_media_account.url,
            service_type: social_media_account.service_name.parameterize,
            title: social_media_account.display_name,
          },
        ],
      },
    }

    presenter = PublishingApi::TopicalEventPresenter.new(topical_event)

    assert_equal expected_hash, presenter.content
    assert_valid_against_schema(presenter.content, "topical_event")
  end

  test "handles topical events without dates" do
    topical_event = create(:topical_event, name: "Humans going to Mars")
    public_path = "/government/topical-events/humans-going-to-mars"

    expected_hash = {
      base_path: public_path,
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      schema_name: "topical_event",
      document_type: "topical_event",
      title: "Humans going to Mars",
      description: topical_event.summary,
      locale: "en",
      routes: [
        {
          path: public_path,
          type: "exact",
        },
      ],
      update_type: "major",
      redirects: [],
      public_updated_at: topical_event.updated_at,
      details: {
        body: Whitehall::GovspeakRenderer.new.govspeak_to_html(topical_event.description),
        ordered_featured_documents: [],
        social_media_links: [],
      },
    }

    presenter = PublishingApi::TopicalEventPresenter.new(topical_event)

    assert_equal expected_hash, presenter.content
    assert_valid_against_schema(presenter.content, "topical_event")
  end

  test "handles topical events without an end_date" do
    topical_event = create(:topical_event, start_date: Time.zone.today)

    presenter = PublishingApi::TopicalEventPresenter.new(topical_event)

    assert_equal({
      body: Whitehall::GovspeakRenderer.new.govspeak_to_html(topical_event.description),
      start_date: Time.zone.today.rfc3339,
      ordered_featured_documents: [],
      social_media_links: [],
    }, presenter.content[:details])
    assert_valid_against_schema(presenter.content, "topical_event")
  end
end
