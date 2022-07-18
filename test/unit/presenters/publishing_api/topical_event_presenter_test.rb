require "test_helper"

class PublishingApi::TopicalEventPresenterTest < ActiveSupport::TestCase
  test "presents a valid topical_event content item" do
    topical_event = create(
      :topical_event,
      :active,
      name: "Humans going to Mars",
      description: "A topical event description with [a link](http://www.gov.uk)",
      logo: upload_fixture("images/960x640_jpeg.jpg", "image/jpeg"),
      logo_alt_text: "Alternative text",
    )
    create(:topical_event_about_page, topical_event: topical_event, read_more_link_text: "Read more about this event")

    first_lead_org = create(:organisation)
    first_lead_org.organisation_classifications.create!(topical_event_id: topical_event.id, lead: true, lead_ordering: 1)
    second_lead_org = create(:organisation)
    second_lead_org.organisation_classifications.create!(topical_event_id: topical_event.id, lead: true, lead_ordering: 2)

    public_path = "/government/topical-events/humans-going-to-mars"

    feature = create(:classification_featuring, topical_event: topical_event, ordering: 1)
    offsite_feature = create(:offsite_classification_featuring, topical_event: topical_event, ordering: 0)

    social_media_service = create(:social_media_service, name: "Facebook")
    social_media_account = create(:social_media_account, social_media_service: social_media_service)
    topical_event.social_media_accounts = [social_media_account]

    expected_hash = {
      base_path: public_path,
      publishing_app: "whitehall",
      rendering_app: "collections",
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
        {
          path: "#{public_path}.atom",
          type: "exact",
        },
      ],
      update_type: "major",
      redirects: [],
      public_updated_at: topical_event.updated_at,
      details: {
        about_page_link_text: topical_event.topical_event_about_page.read_more_link_text,
        body: Whitehall::GovspeakRenderer.new.govspeak_to_html(topical_event.description),
        emphasised_organisations: [first_lead_org.content_id, second_lead_org.content_id],
        image: {
          url: topical_event.logo_url(:s300),
          alt_text: topical_event.logo_alt_text,
        },
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
    assert_valid_against_publisher_schema(presenter.content, "topical_event")
  end

  test "handles topical events without dates" do
    topical_event = create(:topical_event, name: "Humans going to Mars")
    public_path = "/government/topical-events/humans-going-to-mars"

    expected_hash = {
      base_path: public_path,
      publishing_app: "whitehall",
      rendering_app: "collections",
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
        {
          path: "#{public_path}.atom",
          type: "exact",
        },
      ],
      update_type: "major",
      redirects: [],
      public_updated_at: topical_event.updated_at,
      details: {
        body: Whitehall::GovspeakRenderer.new.govspeak_to_html(topical_event.description),
        emphasised_organisations: [],
        ordered_featured_documents: [],
        social_media_links: [],
      },
    }

    presenter = PublishingApi::TopicalEventPresenter.new(topical_event)

    assert_equal expected_hash, presenter.content
    assert_valid_against_publisher_schema(presenter.content, "topical_event")
  end

  test "handles topical events without an end_date" do
    topical_event = create(:topical_event, start_date: Time.zone.today)

    presenter = PublishingApi::TopicalEventPresenter.new(topical_event)

    assert_equal({
      body: Whitehall::GovspeakRenderer.new.govspeak_to_html(topical_event.description),
      start_date: Time.zone.today.rfc3339,
      emphasised_organisations: [],
      ordered_featured_documents: [],
      social_media_links: [],
    }, presenter.content[:details])
    assert_valid_against_publisher_schema(presenter.content, "topical_event")
  end

  test "it limits the number of featured items" do
    topical_event = create(:topical_event, start_date: Time.zone.today)
    create_list(:classification_featuring, FeaturedLink::DEFAULT_SET_SIZE + 1, topical_event: topical_event)

    presenter = PublishingApi::TopicalEventPresenter.new(topical_event)

    assert_equal FeaturedLink::DEFAULT_SET_SIZE, presenter.content.dig(:details, :ordered_featured_documents).length
  end
end
