require "test_helper"

class PublishingApi::HtmlAttachmentPresenterTest < ActiveSupport::TestCase
  def present(record)
    PublishingApi::HtmlAttachmentPresenter.new(record)
  end

  test "HtmlAttachment presentation includes the correct values" do
    government = create(:government)
    edition = create(
      :publication,
      :with_html_attachment,
      :published,
      political: true,
      images: [build(:image)],
    )

    edition.stubs(:government).returns(government)

    html_attachment = edition.html_attachments.first
    html_attachment.govspeak_content.update!(body: "[Image: minister-of-funk.960x640.jpg]")

    expected_hash = {
      base_path: "/government/publications/#{edition.document.slug}/#{html_attachment.slug}",
      title: html_attachment.title,
      description: nil,
      schema_name: "html_publication",
      document_type: "html_publication",
      locale: "en",
      public_updated_at: edition.public_timestamp,
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: "government-frontend",
      routes: [
        { path: html_attachment.url, type: "exact" },
      ],
      redirects: [],
      update_type: "major",
      details: {
        body: ApplicationController.helpers
          .govspeak_html_attachment_to_html(html_attachment),
        public_timestamp: edition.public_timestamp,
        first_published_version: html_attachment.attachable.first_published_version?,
        political: true,
      },
      auth_bypass_ids: [edition.auth_bypass_id],
    }
    presented_item = present(html_attachment)

    assert_valid_against_publisher_schema(presented_item.content, "html_publication")
    assert_valid_against_links_schema({ links: presented_item.links }, "html_publication")

    # We test for HTML equivalance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    presented_content = presented_item.content
    assert_equivalent_html expected_hash[:details].delete(:body),
                           presented_content[:details].delete(:body)

    expected_content = expected_hash.merge(links: presented_item.links)
    assert_equal expected_content, presented_content

    %i[organisations parent primary_publishing_organisation government].each { |k| assert_includes(expected_content[:links].keys, k) }
  end

  test "it includes auto-numbered headers when headers are present in body" do
    html_attachment = create(
      :html_attachment,
      title: "Some html attachment",
      body: "##Some header\n\nSome content",
    )

    presented_html_attachment = PublishingApi::HtmlAttachmentPresenter.new(html_attachment)

    expected_headers = [
      {
        text: "1. Some header",
        level: 2,
        id: "some-header",
      },
    ]

    assert_equal expected_headers, presented_html_attachment.content[:details][:headers]
  end

  test "it includes manually-numbered headers when headers are present in body and manual numbering is on" do
    html_attachment = create(
      :html_attachment,
      title: "Some html attachment",
      body: "##25. Some header\n\nSome content",
      manually_numbered_headings: true,
    )

    presented_html_attachment = PublishingApi::HtmlAttachmentPresenter.new(html_attachment)

    expected_headers = [
      {
        text: "25. Some header",
        level: 2,
        id: "some-header",
      },
    ]

    assert_equal expected_headers, presented_html_attachment.content[:details][:headers]
  end

  test "it does not include headers when headers are not present in body" do
    html_attachment = create(
      :html_attachment,
      title: "Some html attachment",
      body: "Some content",
    )

    presented_html_attachment = PublishingApi::HtmlAttachmentPresenter.new(html_attachment)

    assert_nil presented_html_attachment.content[:details][:headers]
  end

  test "HtmlAttachment presentation includes the correct locale" do
    create(:publication, :with_html_attachment, :published)

    html_attachment = HtmlAttachment.last
    html_attachment.locale = "cy"

    assert_equal "cy", present(html_attachment).content[:locale]
  end

  test "HtmlAttachment presentations sends the parent updated_at if it has no public_timestamp" do
    Timecop.freeze do
      create(:publication, :with_html_attachment, :draft)

      GovspeakContent.delete_all
      html_attachment = HtmlAttachment.last

      assert_equal Time.zone.now, present(html_attachment).content[:details][:public_timestamp]
    end
  end

  test "HtmlAttachment presents unique organisation content_ids" do
    create(:publication, :with_html_attachment, :published)

    html_attachment = HtmlAttachment.last
    # if an organisation has multiple translations, pluck returns
    # duplicate content_ids because it constructs a left outer join
    lead_orgs = mock
    lead_orgs.expects(:pluck).with(:content_id).returns(%w[abcdef])
    html_attachment.attachable.expects(:lead_organisations).returns(lead_orgs).twice

    supporting_orgs = mock
    supporting_orgs.expects(:pluck).with(:content_id).returns(%w[abcdef])
    html_attachment.attachable.expects(:supporting_organisations).returns(supporting_orgs)

    assert_equal %w[abcdef], present(html_attachment).links[:organisations]
  end

  test "HtmlAttachment presents lead organisation content_ids before supporting organisation content_ids" do
    create(:publication, :with_html_attachment, :published)

    html_attachment = HtmlAttachment.last
    # if an organisation has multiple translations, pluck returns
    # duplicate content_ids because it constructs a left outer join
    lead_orgs = mock
    lead_orgs.expects(:pluck).with(:content_id).returns(%w[abcdef])
    html_attachment.attachable.expects(:lead_organisations).returns(lead_orgs).twice

    supporting_orgs = mock
    supporting_orgs.expects(:pluck).with(:content_id).returns(%w[bcdefg])
    html_attachment.attachable.expects(:supporting_organisations).returns(supporting_orgs)

    assert_equal %w[abcdef bcdefg], present(html_attachment).links[:organisations]
  end

  test "HtmlAttachment presents primary_publishing_organisation" do
    create(:publication, :with_html_attachment, :published)

    html_attachment = HtmlAttachment.last

    assert_equal [html_attachment.attachable.lead_organisations.first.content_id],
                 present(html_attachment).links[:primary_publishing_organisation]
  end

  test "HtmlAttachment presents primary_publishing_organisation from 1st org when lead_organisations is not implemented" do
    outcome = create(:consultation_outcome, :with_html_attachment)

    html_attachment = HtmlAttachment.last
    # if an organisation has multiple translations, pluck returns
    # duplicate content_ids because it constructs a left outer join

    presenter = present(html_attachment)
    assert_hash_includes presenter.content, { auth_bypass_ids: [outcome.auth_bypass_id] }
    assert_equal [html_attachment.attachable.organisations.first.content_id],
                 presenter.links[:primary_publishing_organisation]
  end

  test "HtmlAttachments parent object has national_applicability exclusions" do
    scotland_nation_inapplicability = create(
      :nation_inapplicability,
      nation: Nation.scotland,
      alternative_url: "http://scotland.com",
    )
    consultation = create(
      :consultation_with_excluded_nations,
      nation_inapplicabilities: [
        scotland_nation_inapplicability,
      ],
    )

    html_attachment = create(:html_attachment, attachable: consultation)

    presenter = present(html_attachment)
    details = presenter.content[:details]

    expected_national_applicability = {
      england: {
        label: "England",
        applicable: true,
      },
      northern_ireland: {
        label: "Northern Ireland",
        applicable: true,
      },
      scotland: {
        label: "Scotland",
        applicable: false,
        alternative_url: "http://scotland.com",
      },
      wales: {
        label: "Wales",
        applicable: true,
      },
    }

    assert_valid_against_publisher_schema(presenter.content, "html_publication")
    assert_valid_against_links_schema({ links: presenter.links }, "html_publication")
    assert_equal expected_national_applicability, details[:national_applicability]
  end
end
