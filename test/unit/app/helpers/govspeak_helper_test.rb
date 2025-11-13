require "test_helper"

class GovspeakHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL

  it "should not alter urls to other sites" do
    html = govspeak_to_html("no [change](http://external.example.com/page.html)")
    assert_select_within_html html, "a[href=?]", "http://external.example.com/page.html", text: "change"
  end

  it "should not alter mailto urls" do
    html = govspeak_to_html("no [change](mailto:dave@example.com)")
    assert_select_within_html html, "a[href=?]", "mailto:dave@example.com", text: "change"
  end

  it "should not alter invalid urls" do
    html = govspeak_to_html("no [change](not a valid url)")
    assert_select_within_html html, "a[href=?]", "not%20a%20valid%20url", text: "change"
  end

  it "should not alter partial urls" do
    html = govspeak_to_html("no [change](http://)")
    assert_select_within_html html, "a[href=?]", "http://", text: "change"
  end

  it "should wrap output with a govspeak class" do
    html = govspeak_to_html("govspeak-text")
    assert_select_within_html html, ".govspeak", text: "govspeak-text"
  end

  it "should mark the govspeak output as html safe" do
    html = govspeak_to_html("govspeak-text")
    assert html.html_safe?
  end

  it "should produce UTF-8 for HTML entities" do
    html = govspeak_to_html("a ['funny'](/url) thing")
    assert_select_within_html html, "a", text: "‘funny’"
  end

  it "does not change css class on buttons" do
    html = govspeak_to_html("{button}[Link text](https://www.gov.uk){/button}")
    assert_select_within_html html, "a.govuk-button", "Link text"
  end

  it "should not mark admin links as 'external'" do
    speech = create(:published_speech)
    url = admin_speech_url(speech, host: Whitehall.admin_host)
    govspeak = "this and [that](#{url}) yeah?"
    html = govspeak_to_html(govspeak)
    refute_select_within_html html, "a[rel='external']", text: "that"
  end

  it "should not mark public site links as 'external'" do
    speech = create(:published_speech)
    url = admin_speech_url(speech, host: Whitehall.public_host)
    govspeak = "this and [that](#{url}) yeah?"
    html = govspeak_to_html(govspeak)
    refute_select_within_html html, "a[rel='external']", text: "that"
  end

  it "should rewrite admin links for editions" do
    speech = create(:published_speech)
    admin_path = admin_speech_path(speech)
    public_url = speech.public_url

    govspeak = "this and [that](#{admin_path}) yeah?"
    html = govspeak_to_html(govspeak)
    assert_select_within_html html, "a[href='#{public_url}']", text: "that"
  end

  it "should only extract level two headers by default" do
    text = "# Heading 1\n\n## Heading 2\n\n### Heading 3"
    headers = govspeak_headers(text)
    assert_equal [Govspeak::Header.new("Heading 2", 2, "heading-2")], headers
  end

  it "should extract header hierarchy from level 2+3 headings" do
    text = "# Heading 1\n\n## Heading 2a\n\n### Heading 3a\n\n### Heading 3b\n\n#### Ignored heading\n\n## Heading 2b"
    headers = govspeak_header_hierarchy(text)
    assert_equal [
      {
        header: Govspeak::Header.new("Heading 2a", 2, "heading-2a"),
        children: [
          Govspeak::Header.new("Heading 3a", 3, "heading-3a"),
          Govspeak::Header.new("Heading 3b", 3, "heading-3b"),
        ],
      },
      {
        header: Govspeak::Header.new("Heading 2b", 2, "heading-2b"),
        children: [],
      },
    ],
                 headers
  end

  it "should raise exception when extracting header hierarchy with orphaned level 3 headings" do
    e = assert_raise(Govspeak::OrphanedHeadingError) { govspeak_header_hierarchy("### Heading 3") }
    assert_equal "Heading 3", e.heading
  end

  it "should convert single document to govspeak" do
    document = build(:published_news_article, body: "## test")
    html = govspeak_edition_to_html(document)
    assert_select_within_html html, "h2"
  end

  it "should return an empty string if nil edition" do
    assert_equal "", govspeak_edition_to_html(nil)
  end

  def edition_with_attachment(body:)
    attachment = build(:file_attachment, title: "Green paper")
    create(:published_detailed_guide, :with_file_attachment, attachments: [attachment], body:)
  end

  {
    "legacy syntax" => "!@1",
    "Govspeak syntax" => "[Attachment: greenpaper.pdf]",
  }.each do |name, embed_code|
    it "should embed block attachments using #{name}" do
      body = "#Heading\n\n#{embed_code}\n\n##Subheading"
      document = edition_with_attachment(body:)
      html = govspeak_edition_to_html(document)
      assert_select_within_html html, "h1", text: "Heading"
      assert_select_within_html html, ".govspeak > p", count: 0
      assert_select_within_html html, ".gem-c-attachment" do
        assert_select ".gem-c-attachment__title", text: "Green paper"
      end
      assert_select_within_html html, "h2", text: "Subheading"
    end
  end

  {
    "legacy syntax" => "[InlineAttachment:1]",
    "Govspeak syntax" => "[AttachmentLink: greenpaper.pdf]",
  }.each do |name, embed_code|
    it "should embed attachment links inline using #{name}" do
      body = "#Heading\n\nText about my #{embed_code}."
      document = edition_with_attachment(body:)
      html = govspeak_edition_to_html(document)
      assert_select_within_html html, "h1"
      assert_select_within_html html, "p", count: 1 do |paragraph|
        assert_equal "Text about my Green paper (PDF, 3.39 KB, 1 page).", collapse_whitespace(paragraph.text)
      end
      assert_select_within_html html, ".gem-c-attachment-link"
      assert_select_within_html html, ".govuk-link"
    end
  end

  it "should ignore missing block attachments" do
    text = "#Heading\n\n!@2\n\n##Subheading"
    document = build(:published_detailed_guide, :with_file_attachment, body: text)
    html = govspeak_edition_to_html(document)
    assert_select_within_html html, "h1"
    refute_select_within_html html, ".gem-c-attachment"
    assert_select_within_html html, "h2"
  end

  it "should ignore missing inline attachments" do
    text = "#Heading\n\nText about my [InlineAttachment:2]."
    document = build(:published_detailed_guide, :with_file_attachment, body: text)
    html = govspeak_edition_to_html(document)
    assert_select_within_html html, "h1"
    refute_select_within_html html, ".gem-c-attachment-link"
  end

  it "should ignore file attachments with missing asset variants" do
    embed_code = "[Attachment: greenpaper.pdf]"
    body = "#Heading\n\n#{embed_code}\n\n##Subheading"
    attachment = build(:file_attachment_with_no_assets, title: "Green paper")
    document = build(:draft_detailed_guide, :with_file_attachment, attachments: [attachment], body:)

    html = govspeak_edition_to_html(document)
    refute_select_within_html html, ".gem-c-attachment"
  end

  it "should ignore images with missing asset variants" do
    embed_code = "[Image: minister-of-funk.960x640.jpg]"
    body = "#Heading\n\n#{embed_code}\n\n##Subheading"
    image = build(:image_with_no_assets)
    image.image_data.assets = [build(:asset), build(:asset, variant: Asset.variants[:s960])]
    image.image_data.save!
    document = build(:published_news_article, images: [image], body:)

    html = govspeak_edition_to_html(document)
    refute_select_within_html html, ".image.embedded"
  end

  it "should ignore images with image kinds which do not permit use in govspeak embeds" do
    embed_code = "[Image: minister-of-funk.960x640.jpg]"
    body = "#Heading\n\n#{embed_code}\n\n##Subheading"
    image = build(:image)
    image_data = image.image_data
    def image_data.image_kind_config = Whitehall::ImageKind.new(
      "some name",
      "display_name" => "some display name",
      "valid_width" => 0,
      "valid_height" => 0,
      "permitted_uses" => [],
      "versions" => [],
    )
    document = build(:published_news_article, images: [image], body:)

    html = govspeak_edition_to_html(document)
    refute_select_within_html html, ".image.embedded"
  end

  it "should not convert documents with no block attachments" do
    text = "#Heading\n\n!@2"
    document = build(:published_detailed_guide, body: text)
    html = govspeak_edition_to_html(document)
    refute_select_within_html html, ".gem-c-attachment"
  end

  it "should not convert documents with no inline attachments" do
    text = "#Heading\n\nText about my [InlineAttachment:2]."
    document = build(:published_detailed_guide, body: text)
    html = govspeak_edition_to_html(document)
    refute_select_within_html html, ".gem-c-attachment-link"
  end

  {
    "legacy syntax" => "#heading\n\n!@1\n\n!@2",
    "Govspeak syntax" => "#heading\n\n[Attachment: greenpaper.pdf]\n\n[Attachment: sample.csv]",
    "a mixture of both legacy and Govspeak syntax" => "#heading\n\n[Attachment: greenpaper.pdf]\n\n!@2",
  }.each do |name, document_body|
    it "should convert multiple block attachments using #{name}" do
      document = build(
        :published_detailed_guide,
        body: document_body,
        attachments: [
          create(:file_attachment, title: "First attachment"),
          create(:csv_attachment, title: "Second attachment"),
        ],
      )
      html = govspeak_edition_to_html(document)
      assert_select_within_html html, ".govspeak > p", count: 0
      assert_select_within_html html, ".govspeak h2", count: 2 do |matches|
        assert_equal "First attachment", matches[0].text.strip
        assert_equal "Second attachment", matches[1].text.strip
      end
    end
  end

  {
    "legacy syntax" => "#Heading\n\nText about my [InlineAttachment:1] and [InlineAttachment:2].",
    "Govspeak syntax" => "#Heading\n\nText about my [AttachmentLink: greenpaper.pdf] and [AttachmentLink: sample.csv].",
    "a mixture of both legacy and Govspeak syntax" => "#Heading\n\nText about my [AttachmentLink: greenpaper.pdf] and [InlineAttachment:2].",
  }.each do |name, document_body|
    it "should convert multiple inline attachments using #{name}" do
      document = build(
        :published_detailed_guide,
        body: document_body,
        attachments: [
          create(:file_attachment, title: "First attachment"),
          create(:csv_attachment, title: "Second attachment"),
        ],
      )
      html = govspeak_edition_to_html(document)
      assert_select_within_html html, "p", count: 1
      assert_select_within_html html, ".gem-c-attachment-link", count: 2 do |matches|
        assert_equal "First attachment (PDF, 3.39 KB, 1 page)", collapse_whitespace(matches[0].text)
        assert_equal "Second attachment (CSV, 132 Bytes)", collapse_whitespace(matches[1].text)
      end
    end
  end

  it "should not escape embedded attachment when attachment embed code only separated by one newline from a previous paragraph" do
    text = "para\n!@1"
    document = build(:published_detailed_guide, :with_file_attachment, body: text)
    html = govspeak_edition_to_html(document)
    assert_not html.include?("&lt;div"), "should not escape embedded attachment"
    assert_select_within_html html, ".gem-c-attachment__thumbnail"
  end

  it "embeds images using !!number syntax" do
    edition = build(:published_news_article, images: [build(:image)], body: "!!1")
    html = govspeak_edition_to_html(edition)
    assert_select_within_html html, ".govspeak figure.image.embedded img[src='#{edition.images.first.embed_url}']"
  end

  it "embeds images using [Image:] syntax" do
    edition = build(:published_news_article, images: [build(:image)], body: "[Image: minister-of-funk.960x640.jpg]")
    html = govspeak_edition_to_html(edition)
    assert_select_within_html html, ".govspeak figure.image.embedded img[src='#{edition.images.first.embed_url}']"
  end

  it "adds numbers to h2 headings" do
    input = "# main\n\n## first\n\n## second"
    output = '<div class="govspeak"><h1 id="main">main</h1> <h2 id="first">1. first</h2> <h2 id="second">2. second</h2></div>'
    assert_equivalent_html output, collapse_whitespace(govspeak_to_html(input, auto_numbered_headers: true))
  end

  it "adds sub-numbers to h3 tags" do
    input = "## first\n\n### first point one\n\n### first point two\n\n## second\n\n### second point one"
    expected_output1 = '<h2 id="first">1. first</h2>'
    expected_output_1a = '<h3 id="first-point-one">1.1 first point one</h3>'
    expected_output_1b = '<h3 id="first-point-two">1.2 first point two</h3>'
    expected_output2 = '<h2 id="second">2. second</h2>'
    expected_output_2a = '<h3 id="second-point-one">2.1 second point one</h3>'
    actual_output = collapse_whitespace(govspeak_to_html(input, auto_numbered_headers: true))
    assert_match %r{#{expected_output1}}, actual_output
    assert_match %r{#{expected_output_1a}}, actual_output
    assert_match %r{#{expected_output_1b}}, actual_output
    assert_match %r{#{expected_output2}}, actual_output
    assert_match %r{#{expected_output_2a}}, actual_output
  end

  it "should not corrupt character encoding of numbered headings" do
    input = "# café"
    actual_output = govspeak_to_html(input, auto_numbered_headers: true)
    assert actual_output.include?("café</h1>")
  end

  it "should not turn h4 headings into h3s" do
    input = "#### Level 4 Heading"
    actual_output = govspeak_to_html(input, auto_numbered_headers: false)
    assert_equal "<div class=\"govspeak\"><h4 id=\"level-4-heading\">Level 4 Heading</h4>\n</div>", actual_output
  end

  it "converts [Contact:<id>] into a rendering of contacts/_contact for the Contact with id = <id>" do
    contact = build(:contact)
    Contact.stubs(:find_by).with(id: "1").returns(contact)
    input = "[Contact:1]"
    output = govspeak_to_html(input)
    contact_html = render("contacts/contact", contact:, heading_tag: "p")
    assert_equivalent_html "<div class=\"govspeak\">#{contact_html}</div>", output
  end

  it "adds manual numbering to heading tags" do
    input = "## 1. Main\n\n## 2. Second\n\n### Sub heading without a number\n\n## 42.12 Out of sequence"
    expected_output = '<div class="govspeak"><h2 id="main">1. Main</h2> <h2 id="second">2. Second</h2> <h3 id="sub-heading-without-a-number">Sub heading without a number</h3> <h2 id="out-of-sequence">42.12 Out of sequence</h2></div>'
    assert_equivalent_html expected_output, collapse_whitespace(govspeak_to_html(input))
  end

  it "avoids adding manual numbering to heading tags that start with numbers but aren't intended for manual numbering" do
    # NB, the reason we expect a `gd-not-all-numeric-characters` ID rather than
    #  a `0gd-not-all-numeric-characters` is that pre-HTML5 IDs _must_ begin with
    # a letter: https://www.w3.org/TR/html4/types.html#type-id
    # See also this issue in Kramdown:
    # https://github.com/gettalong/kramdown/issues/711
    input = "## 0GD Not all numeric characters"
    expected_output = '<div class="govspeak"><h2 id="gd-not-all-numeric-characters">0GD Not all numeric characters</h2></div>'
    assert_equivalent_html expected_output, govspeak_to_html(input).gsub(/\s+/, " ")
  end

  it "leaves heading numbers not occuring at the start of the heading text alone when using manual heading numbering" do
    input = "## Number 8"
    result = Nokogiri::HTML::DocumentFragment.parse(govspeak_to_html(input))
    assert_equal "Number 8", result.css("h2").first.text
  end

  it "handles leading numbers and symbols" do
    input = "## £100,000 header text here"
    expected_output = '<div class="govspeak"><h2 id="header-text-here">1. £100,000 header text here</h2></div>'
    assert_equivalent_html expected_output, collapse_whitespace(govspeak_to_html(input, auto_numbered_headers: true))
  end

  it "can manage a custom ID in the govspeak" do
    input = "## £100,000 header text here {#custom-id}"
    expected_output = '<div class="govspeak"><h2 id="custom-id">1. £100,000 header text here</h2></div>'
    assert_equivalent_html expected_output, collapse_whitespace(govspeak_to_html(input, auto_numbered_headers: true))
  end

  it "can manage a custom ID with leading numbers" do
    input = "## £100,000 header text here {#10-custom-id}"
    expected_output = '<div class="govspeak"><h2 id="custom-id">1. £100,000 header text here</h2></div>'
    assert_equivalent_html expected_output, collapse_whitespace(govspeak_to_html(input, auto_numbered_headers: true))
  end

  it "converts [Contact:<id>] into a rendering of contacts/_contact for the Contact with id = <id> with defined header level" do
    contact = build(:contact)
    Contact.stubs(:find_by).with(id: "1").returns(contact)
    input = "[Contact:1]"
    output = govspeak_to_html(input, contact_heading_tag: "p")
    contact_html = render("contacts/contact", contact:, heading_tag: "p")
    assert_equivalent_html "<div class=\"govspeak\">#{contact_html}</div>", output
  end

  it "silently converts [Contact:<id>] into nothing if there is no Contact with id = <id>" do
    Contact.stubs(:find_by).with(id: "1").returns(nil)
    input = "[Contact:1]"
    output = govspeak_to_html(input)
    assert_equivalent_html "<div class=\"govspeak\"></div>", output
  end

  it "will use the html version of the contact partial, even if the view context is for a different format" do
    contact = build(:contact)
    Contact.stubs(:find_by).with(id: "1").returns(contact)
    input = "[Contact:1]"
    contact_html = render("contacts/contact", contact:, heading_tag: "p")
    controller.lookup_context.formats = %i[atom]
    assert_nothing_raised do
      assert_equivalent_html "<div class=\"govspeak\">#{contact_html}</div>", govspeak_to_html(input)
    end
  end

  it "should convert a HTML attachment" do
    html_attachment = create(:html_attachment, body: "## A heading")
    html = govspeak_html_attachment_to_html(html_attachment)
    assert_select_within_html html, ".govspeak h2"
  end

  it "HTML attachments inherit images from their parent edition" do
    edition = create(:published_publication, images: [build(:image)])
    body = "[Image: minister-of-funk.960x640.jpg]"
    html_attachment = create(:html_attachment, attachable: edition, body:)
    html = govspeak_html_attachment_to_html(html_attachment)
    assert_select_within_html html, ".govspeak figure.image.embedded img[src='#{edition.images.first.embed_url}']"
  end

  it "HTML attachments can embed images using !!number syntax" do
    edition = create(:published_publication, images: [build(:image)])
    html_attachment = create(:html_attachment, attachable: edition, body: "!!1")
    html = govspeak_html_attachment_to_html(html_attachment)
    assert_select_within_html html, ".govspeak figure.image.embedded img[src='#{edition.images.first.embed_url}']"
  end

  it "HTML attachment with automatically numbered headings" do
    html_attachment = create(:html_attachment, body: "## A heading", manually_numbered_headings: false)
    html = govspeak_html_attachment_to_html(html_attachment)
    assert_select_within_html html, ".govspeak h2", text: "1. A heading", count: 1
  end

  it "HTML attachment with manually numbered headings" do
    html_attachment = create(:html_attachment, body: "## A heading", manually_numbered_headings: true)
    html = govspeak_html_attachment_to_html(html_attachment)
    assert_select_within_html html, ".govspeak h2", text: "A heading", count: 1
  end

  it "HTML attachments cannot embed attachments from their parent edition" do
    body = <<~MARKDOWN
      Every way to embed an attachment:

      [InlineAttachment:1]
      [AttachmentLink:sample.csv]
      !@1
      [Attachment:sample.csv]
    MARKDOWN

    create(
      :published_publication,
      attachments: [
        build(:csv_attachment),
        html_attachment = build(:html_attachment, body:),
      ],
      alternative_format_provider: build(:organisation, :with_alternative_format_contact_email),
    )

    html = govspeak_html_attachment_to_html(html_attachment)
    assert_equivalent_html '<div class="govspeak"><p>Every way to embed an attachment:</p></div>', html
  end

  it "uses locale of HTML attachment" do
    body = <<~MARKDOWN
      Footnote[^1]

      [^1]: Description
    MARKDOWN

    html_attachment = create(:html_attachment, body:, locale: "cy")

    html = govspeak_html_attachment_to_html(html_attachment)
    assert_select_within_html html, "a", text: "[troednodyn 1]", count: 1
  end

  describe "admin flavour of govspeak" do
    include Admin::EditionRoutesHelper

    it "should wrap admin output with a govspeak class" do
      html = govspeak_to_html("govspeak-text", { preview: true })
      assert_select_within_html html, ".govspeak", text: "govspeak-text"
    end

    it "should mark the admin govspeak output as html safe" do
      html = govspeak_to_html("govspeak-text", { preview: true })
      assert html.html_safe?
    end

    it "should not alter mailto urls in the admin preview" do
      html = govspeak_to_html("no [change](mailto:dave@example.com)", { preview: true })
      assert_select_within_html html, "a[href=?]", "mailto:dave@example.com", text: "change"
    end

    it "should not alter urls to other sites in the admin preview" do
      html = govspeak_to_html("no [change](http://external.example.com/page.html)", { preview: true })
      assert_select_within_html html, "a[href=?]", "http://external.example.com/page.html", text: "change"
    end

    it "should not alter partial urls in the admin preview" do
      html = govspeak_to_html("no [change](http://)", { preview: true })
      assert_select_within_html html, "a[href=?]", "http://", text: "change"
    end

    it "should rewrite link to draft edition in admin preview" do
      publication = create(:draft_publication)
      html = govspeak_to_html("this and [that](#{admin_publication_path(publication)})", { preview: true })
      assert_select_within_html html, "a[href=?]", admin_publication_path(publication), text: "draft"
    end

    it "should not alter unicode when replacing links" do
      publication = create(:published_publication)
      html = govspeak_to_html("the [☃](#{admin_publication_path(publication)})", { preview: true })
      assert_select_within_html html, "a[href=?]", publication.public_url, text: "☃"
    end

    it "should rewrite link to deleted edition in admin preview" do
      publication = create(:deleted_publication)
      html = govspeak_to_html("this and [that](#{admin_publication_path(publication)})", { preview: true })
      assert_select_within_html html, "del", text: "that"
    end

    it "should rewrite link to missing edition in admin preview" do
      html = govspeak_to_html("this and [that](#{admin_publication_path('98765')})", { preview: true })
      assert_select_within_html html, "del", text: "that"
    end

    it "should rewrite link to bad edition ID in admin preview" do
      html = govspeak_to_html("this and [that](#{admin_publication_path('not-an-id')})", { preview: true })
      assert_select_within_html html, "del", text: "that"
    end

    it "should rewrite link to published edition in admin preview" do
      publication = create(:published_publication)
      html = govspeak_to_html("this and [that](#{admin_publication_path(publication)})", { preview: true })
      assert_select_within_html html, "a[href=?]", publication.public_url, text: "that"
    end

    it "should rewrite link to published edition with a newer draft in admin preview" do
      publication = create(:published_publication)
      new_draft = publication.create_draft(create(:writer))
      html = govspeak_to_html("this and [that](#{admin_publication_path(publication)})", { preview: true })
      assert_select_within_html html, "a[href=?]", admin_publication_path(new_draft), text: "draft"
    end

    it "should rewrite link to superseded edition with a newer published edition in admin preview" do
      publication = create(:published_publication)
      writer = create(:writer)
      new_edition = publication.create_draft(writer)
      new_edition.change_note = "change-note"
      new_edition.save_as(writer)
      new_edition.submit!
      publish(new_edition)
      html = govspeak_to_html("this and [that](#{admin_publication_path(publication)})", { preview: true })
      assert_select_within_html html, "a[href=?]", admin_publication_path(new_edition), text: "published"
    end

    it "should rewrite link to deleted edition with an older published edition in admin preview" do
      document = create(:document)
      publication = create(:published_publication, document:)
      deleted_edition = create(:deleted_publication, document:)
      html = govspeak_to_html("this and [that](#{admin_publication_path(deleted_edition)})", { preview: true })
      assert_select_within_html html, "a[href=?]", admin_publication_path(publication), text: "published"
    end

    it "should allow attached images to be embedded in admin html" do
      image = build(:image)
      html = govspeak_to_html("!!1", images: [image], preview: true)
      assert_select_within_html html, ".govspeak figure.image.embedded img[src=?]", image.embed_url
    end

    it "should allow attached images to be embedded in edition body" do
      image = build(:image)
      edition = build(:published_news_article, body: "!!1", images: [image])
      html = govspeak_edition_to_html(edition, { preview: true })
      assert_select_within_html html, ".govspeak figure.image.embedded img[src=?]", image.embed_url
    end

    it "uses the frontend contacts/_contact partial when rendering embedded contacts, not the admin partial" do
      contact = build(:contact)
      Contact.stubs(:find_by).with(id: "1").returns(contact)
      input = "[Contact:1]"
      output = govspeak_to_html(input, { preview: true })
      contact_html = render("contacts/contact", contact:, heading_tag: "p")
      assert_equivalent_html "<div class=\"govspeak\">#{contact_html}</div>", output
    end

    it "use the frontend html version of the contact partial, even if the view context is for a different format" do
      contact = build(:contact)
      Contact.stubs(:find_by).with(id: "1").returns(contact)
      input = "[Contact:1]"
      contact_html = render("contacts/contact", contact:, heading_tag: "p")
      controller.lookup_context.formats = %i[atom]
      assert_nothing_raised do
        assert_equivalent_html "<div class=\"govspeak\">#{contact_html}</div>", govspeak_to_html(input, { preview: true })
      end
    end

    it "should call the embed codes helper" do
      input = "Here is some Govspeak"
      expected = "Expected output"
      ContentBlock::FindAndReplaceEmbedCodesService.expects(:call).with(input).returns(expected)
      govspeak_to_html(input, { preview: true })
    end
  end

private

  def collapse_whitespace(string)
    string.gsub(/\s+/, " ").strip
  end
end
