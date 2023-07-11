require "test_helper"

class GovspeakHelperTest < ActionView::TestCase
  test "should not alter urls to other sites" do
    html = govspeak_to_html("no [change](http://external.example.com/page.html)")
    assert_select_within_html html, "a[href=?]", "http://external.example.com/page.html", text: "change"
  end

  test "should not alter mailto urls" do
    html = govspeak_to_html("no [change](mailto:dave@example.com)")
    assert_select_within_html html, "a[href=?]", "mailto:dave@example.com", text: "change"
  end

  test "should not alter invalid urls" do
    html = govspeak_to_html("no [change](not a valid url)")
    assert_select_within_html html, "a[href=?]", "not%20a%20valid%20url", text: "change"
  end

  test "should not alter partial urls" do
    html = govspeak_to_html("no [change](http://)")
    assert_select_within_html html, "a[href=?]", "http://", text: "change"
  end

  test "should wrap output with a govspeak class" do
    html = govspeak_to_html("govspeak-text")
    assert_select_within_html html, ".govspeak", text: "govspeak-text"
  end

  test "should mark the govspeak output as html safe" do
    html = govspeak_to_html("govspeak-text")
    assert html.html_safe?
  end

  test "should produce UTF-8 for HTML entities" do
    html = govspeak_to_html("a ['funny'](/url) thing")
    assert_select_within_html html, "a", text: "‘funny’"
  end

  test "should add govuk-link class to links" do
    html = govspeak_to_html("[Link text](https://www.gov.uk)")
    assert_select_within_html html, "a.govuk-link", "Link text"
  end

  test "does not change css class on buttons" do
    html = govspeak_to_html("{button}[Link text](https://www.gov.uk){/button}")
    assert_select_within_html html, "a.govuk-button", "Link text"
  end

  test "should not mark admin links as 'external'" do
    speech = create(:published_speech)
    url = admin_speech_url(speech, host: Whitehall.admin_host)
    govspeak = "this and [that](#{url}) yeah?"
    html = govspeak_to_html(govspeak)
    refute_select_within_html html, "a[rel='external']", text: "that"
  end

  test "should not mark public site links as 'external'" do
    speech = create(:published_speech)
    url = admin_speech_url(speech, host: Whitehall.public_host)
    govspeak = "this and [that](#{url}) yeah?"
    html = govspeak_to_html(govspeak)
    refute_select_within_html html, "a[rel='external']", text: "that"
  end

  test "should rewrite admin links for editions" do
    speech = create(:published_speech)
    admin_path = admin_speech_path(speech)
    public_url = speech.public_url

    govspeak = "this and [that](#{admin_path}) yeah?"
    html = govspeak_to_html(govspeak)
    assert_select_within_html html, "a[href='#{public_url}']", text: "that"
  end

  test "should only extract level two headers by default" do
    text = "# Heading 1\n\n## Heading 2\n\n### Heading 3"
    headers = govspeak_headers(text)
    assert_equal [Govspeak::Header.new("Heading 2", 2, "heading-2")], headers
  end

  test "should extract header hierarchy from level 2+3 headings" do
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

  test "should raise exception when extracting header hierarchy with orphaned level 3 headings" do
    e = assert_raise(Govspeak::OrphanedHeadingError) { govspeak_header_hierarchy("### Heading 3") }
    assert_equal "Heading 3", e.heading
  end

  test "should convert single document to govspeak" do
    document = build(:published_news_article, body: "## test")
    html = govspeak_edition_to_html(document)
    assert_select_within_html html, "h2"
  end

  test "should return an empty string if nil edition" do
    assert_equal "", govspeak_edition_to_html(nil)
  end

  test "should optionally not wrap output in a govspeak class" do
    document = build(:published_news_article, body: "govspeak-text")
    html = bare_govspeak_edition_to_html(document)
    assert_select_within_html html, ".govspeak", false
    assert_select_within_html html, "p", "govspeak-text"
  end

  def edition_with_attachment(body:)
    attachment = build(:file_attachment, title: "Green paper")
    create(:published_detailed_guide, :with_file_attachment, attachments: [attachment], body:)
  end

  {
    "legacy syntax" => "!@1",
    "Govspeak syntax" => "[Attachment: greenpaper.pdf]",
  }.each do |name, embed_code|
    test "should embed block attachments using #{name}" do
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
    test "should embed attachment links inline using #{name}" do
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

  test "should ignore missing block attachments" do
    text = "#Heading\n\n!@2\n\n##Subheading"
    document = build(:published_detailed_guide, :with_file_attachment, body: text)
    html = govspeak_edition_to_html(document)
    assert_select_within_html html, "h1"
    refute_select_within_html html, ".gem-c-attachment"
    assert_select_within_html html, "h2"
  end

  test "should ignore missing inline attachments" do
    text = "#Heading\n\nText about my [InlineAttachment:2]."
    document = build(:published_detailed_guide, :with_file_attachment, body: text)
    html = govspeak_edition_to_html(document)
    assert_select_within_html html, "h1"
    refute_select_within_html html, ".gem-c-attachment-link"
  end

  test "should not convert documents with no block attachments" do
    text = "#Heading\n\n!@2"
    document = build(:published_detailed_guide, body: text)
    html = govspeak_edition_to_html(document)
    refute_select_within_html html, ".gem-c-attachment"
  end

  test "should not convert documents with no inline attachments" do
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
    test "should convert multiple block attachments using #{name}" do
      document = build(
        :published_detailed_guide,
        body: document_body,
        attachments: [
          create(:file_attachment, title: "First attachment", file: upload_fixture("greenpaper.pdf", "application/pdf")),
          create(:file_attachment, title: "Second attachment", file: upload_fixture("sample.csv", "text/csv")),
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
    test "should convert multiple inline attachments using #{name}" do
      document = build(
        :published_detailed_guide,
        body: document_body,
        attachments: [
          create(:file_attachment, title: "First attachment", file: upload_fixture("greenpaper.pdf", "application/pdf")),
          create(:file_attachment, title: "Second attachment", file: upload_fixture("sample.csv", "text/csv")),
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

  test "should not escape embedded attachment when attachment embed code only separated by one newline from a previous paragraph" do
    text = "para\n!@1"
    document = build(:published_detailed_guide, :with_file_attachment, body: text)
    html = govspeak_edition_to_html(document)
    assert_not html.include?("&lt;div"), "should not escape embedded attachment"
    assert_select_within_html html, ".gem-c-attachment__thumbnail"
  end

  test "embeds images using !!number syntax" do
    edition = build(:published_news_article, body: "!!1")
    image_data = create(:image_data, id: 1)
    edition.stubs(:images).returns([OpenStruct.new(alt_text: "My Alt", url: "https://some.cdn.com/image.jpg", image_data: ImageData.find(image_data.id))])
    html = govspeak_edition_to_html(edition)
    assert_select_within_html html, ".govspeak figure.image.embedded img[src='https://some.cdn.com/image.jpg']"
  end

  test "embeds images using [Image:] syntax" do
    edition = build(:published_news_article, body: "[Image: minister-of-funk.960x640.jpg]")
    image_data = create(:image_data, id: 1)
    edition.stubs(:images).returns([OpenStruct.new(alt_text: "My Alt", url: "https://some.cdn.com/image.jpg", image_data: ImageData.find(image_data.id))])
    html = govspeak_edition_to_html(edition)
    assert_select_within_html html, ".govspeak figure.image.embedded img[src='https://some.cdn.com/image.jpg']"
  end

  test "should remove extra quotes from blockquote text" do
    remover = stub("remover")
    remover.expects(:remove).returns("remover return value")
    Whitehall::ExtraQuoteRemover.stubs(:new).returns(remover)
    edition = build(:published_news_article, body: %(He said:\n> "I'm not sure what you mean!"\nOr so we thought.))
    assert_match %r{remover return value}, govspeak_edition_to_html(edition)
  end

  test "should add class to last paragraph of blockquote" do
    input = "\n> firstline\n>\n> lastline\n"
    output = '<div class="govspeak"> <blockquote> <p>firstline</p> <p class="last-child">lastline</p> </blockquote></div>'
    assert_equivalent_html output, govspeak_to_html(input).gsub(/\s+/, " ")
  end

  test "adds numbers to h2 headings" do
    input = "# main\n\n## first\n\n## second"
    output = '<div class="govspeak"><h1 id="main">main</h1> <h2 id="first"> <span class="number">1. </span>first</h2> <h2 id="second"> <span class="number">2. </span>second</h2></div>'
    assert_equivalent_html output, govspeak_to_html(input, heading_numbering: :auto).gsub(/\s+/, " ")
  end

  test "adds sub-numbers to h3 tags" do
    input = "## first\n\n### first point one\n\n### first point two\n\n## second\n\n### second point one"
    expected_output1 = '<h2 id="first"> <span class="number">1. </span>first</h2>'
    expected_output_1a = '<h3 id="first-point-one"> <span class="number">1.1 </span>first point one</h3>'
    expected_output_1b = '<h3 id="first-point-two"> <span class="number">1.2 </span>first point two</h3>'
    expected_output2 = '<h2 id="second"> <span class="number">2. </span>second</h2>'
    expected_output_2a = '<h3 id="second-point-one"> <span class="number">2.1 </span>second point one</h3>'
    actual_output = govspeak_to_html(input, heading_numbering: :auto).gsub(/\s+/, " ")
    assert_match %r{#{expected_output1}}, actual_output
    assert_match %r{#{expected_output_1a}}, actual_output
    assert_match %r{#{expected_output_1b}}, actual_output
    assert_match %r{#{expected_output2}}, actual_output
    assert_match %r{#{expected_output_2a}}, actual_output
  end

  test "adds manual numbering to heading tags" do
    input = "## 1. Main\n\n## 2. Second\n\n### Sub heading without a number\n\n## 42.12 Out of sequence\n\n## 0GD Not all numeric characters"
    expected_output = '<div class="govspeak"><h2 id="main"> <span class="number">1. </span> Main</h2> <h2 id="second"> <span class="number">2. </span> Second</h2> <h3 id="sub-heading-without-a-number">Sub heading without a number</h3> <h2 id="out-of-sequence"> <span class="number">42.12 </span> Out of sequence</h2> <h2 id="gd-not-all-numeric-characters"> <span class="number">0GD </span> Not all numeric characters</h2></div>'
    assert_equivalent_html expected_output, govspeak_to_html(input, heading_numbering: :manual).gsub(/\s+/, " ")
  end

  test "leaves heading numbers not occuring at the start of the heading text alone when using manual heading numbering" do
    input = "## Number 8"
    result = Nokogiri::HTML::DocumentFragment.parse(govspeak_to_html(input, heading_numbering: :manual))
    assert_equal "Number 8", result.css("h2").first.text
  end

  test "should not corrupt character encoding of numbered headings" do
    input = "# café"
    actual_output = govspeak_to_html(input, heading_numbering: :auto)
    assert actual_output.include?("café</h1>")
  end

  test "converts [Contact:<id>] into a rendering of contacts/_contact for the Contact with id = <id>" do
    contact = build(:contact)
    Contact.stubs(:find_by).with(id: "1").returns(contact)
    input = "[Contact:1]"
    output = govspeak_to_html(input)
    contact_html = render("contacts/contact", contact:, heading_tag: "p")
    assert_equivalent_html "<div class=\"govspeak\">#{contact_html}</div>", output
  end

  test "converts [Contact:<id>] into a rendering of contacts/_contact for the Contact with id = <id> with defined header level" do
    contact = build(:contact)
    Contact.stubs(:find_by).with(id: "1").returns(contact)
    input = "[Contact:1]"
    output = govspeak_to_html(input, contact_heading_tag: "p")
    contact_html = render("contacts/contact", contact:, heading_tag: "p")
    assert_equivalent_html "<div class=\"govspeak\">#{contact_html}</div>", output
  end

  test "silently converts [Contact:<id>] into nothing if there is no Contact with id = <id>" do
    Contact.stubs(:find_by).with(id: "1").returns(nil)
    input = "[Contact:1]"
    output = govspeak_to_html(input)
    assert_equivalent_html "<div class=\"govspeak\"></div>", output
  end

  test "will use the html version of the contact partial, even if the view context is for a different format" do
    contact = build(:contact)
    Contact.stubs(:find_by).with(id: "1").returns(contact)
    input = "[Contact:1]"
    contact_html = render("contacts/contact", contact:, heading_tag: "p")
    @controller.lookup_context.formats = %i[atom]
    assert_nothing_raised do
      assert_equivalent_html "<div class=\"govspeak\">#{contact_html}</div>", govspeak_to_html(input)
    end
  end

  test "will add a barchart class to a marked table" do
    input = <<~INPUT
      |col|
      |---|
      |val|
      {barchart}
    INPUT
    html = govspeak_to_html(input)
    assert_select_within_html html, "table.js-barchart-table"
  end

  test "will add a stacked, compact, negative barchart class to a marked table" do
    input = <<~INPUT
      |col|
      |---|
      |val|
      {barchart stacked compact negative}
    INPUT
    html = govspeak_to_html(input)
    assert_select_within_html html, "table.mc-stacked.js-barchart-table.mc-negative.compact"
  end

  test "will make a marked table sortable" do
    input = <<~INPUT
      |col|
      |---|
      |val|
      {sortable}
    INPUT
    html = govspeak_to_html(input)
    assert_select_within_html html, "table.sortable"
  end

  test "will make a marked table sortable and a barchart" do
    input = <<~INPUT
      |col|
      |---|
      |val|
      {sortable}
      {barchart}
    INPUT

    html = govspeak_to_html(input)
    assert_select_within_html html, "table.sortable.js-barchart-table"
  end

  test "fraction image paths include the public asset host and configured asset prefix" do
    prefix = Rails.application.config.assets.prefix
    path   = "#{Whitehall.public_root}#{prefix}/fractions/1_2.png"
    html   = govspeak_to_html("I'm [Fraction:1/2] a person")

    assert_select_within_html(html, "img[src='#{path}']")
  end

  test "will create bespoke fractions" do
    input = "Some text [Fraction:1/72] and some text"
    html = govspeak_to_html(input)
    assert_select_within_html html, "span.fraction > sup", text: "1"
    assert_select_within_html html, "span.fraction > sub", text: "72"
  end

  test "will create fractions using images for a known set" do
    input = "Some text [Fraction:1/4] and some text"
    html = govspeak_to_html(input)
    assert_select_within_html html, "span.fraction > img[alt='1/4']"
  end

  test "will create algebraic and trigonometric fractions using images for a known set" do
    input = "Some text [Fraction:c/sinC] and some text"
    html = govspeak_to_html(input)
    assert_select_within_html html, "span.fraction > img[alt='c/sinC']"

    input = "Some text [Fraction:1/x] and some text"
    html = govspeak_to_html(input)
    assert_select_within_html html, "span.fraction > img[alt='1/x']"

    input = "Some text with an uppercased fraction [Fraction:1/X] and some text"
    html = govspeak_to_html(input)
    assert_select_within_html html, "span.fraction > img[alt='1/x']"
  end

  test "should convert a HTML attachment" do
    html_attachment = create(:html_attachment, body: "## A heading")
    html = govspeak_html_attachment_to_html(html_attachment)
    assert_select_within_html html, ".govspeak h2"
  end

  test "HTML attachments inherit images from their parent edition" do
    edition = create(:published_publication, images: [build(:image)])
    body = "[Image: minister-of-funk.960x640.jpg]"
    html_attachment = create(:html_attachment, attachable: edition, body:)
    html = govspeak_html_attachment_to_html(html_attachment)
    assert_select_within_html html, ".govspeak figure.image.embedded img[src='#{edition.images.first.url}']"
  end

  test "HTML attachments can embed images using !!number syntax" do
    edition = create(:published_publication, images: [build(:image)])
    html_attachment = create(:html_attachment, attachable: edition, body: "!!1")
    html = govspeak_html_attachment_to_html(html_attachment)
    assert_select_within_html html, ".govspeak figure.image.embedded img[src='#{edition.images.first.url}']"
  end

  test "HTML attachment with automatically numbered headings" do
    html_attachment = create(:html_attachment, body: "## A heading", manually_numbered_headings: false)
    html = govspeak_html_attachment_to_html(html_attachment)
    assert_select_within_html html, ".govspeak h2", text: "1. A heading", count: 1
  end

  test "HTML attachment with manually numbered headings" do
    html_attachment = create(:html_attachment, body: "## A heading", manually_numbered_headings: true)
    html = govspeak_html_attachment_to_html(html_attachment)
    assert_select_within_html html, ".govspeak h2", text: "A heading", count: 1
  end

private

  def collapse_whitespace(string)
    string.gsub(/\s+/, " ").strip
  end
end
