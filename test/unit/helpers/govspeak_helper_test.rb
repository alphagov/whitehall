# encoding: UTF-8

require 'test_helper'

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
    public_url = Whitehall.url_maker.public_document_url(speech)

    govspeak = "this and [that](#{admin_path}) yeah?"
    html = govspeak_to_html(govspeak)
    assert_select_within_html html, "a[href='#{public_url}']", text: "that"
  end

  test "should allow attached images to be embedded in public html" do
    images = [OpenStruct.new(alt_text: "My Alt", url: "http://example.com/image.jpg")]
    html = govspeak_to_html("!!1", images)
    assert_select_within_html html, ".govspeak figure.image.embedded img"
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
          Govspeak::Header.new("Heading 3b", 3, "heading-3b")
        ]
      },
      {
        header: Govspeak::Header.new("Heading 2b", 2, "heading-2b"),
        children: []
      }
    ], headers
  end

  test "#html_attachment_govspeak_headers add number markup for manually numbered HTML attachments" do
    attachment = build(:html_attachment,
                       body: "## 1. First\n\n## 2. Second\n\n### 2.1 Sub",
                       manually_numbered_headings: true)
    expected_headings = [Govspeak::Header.new("<span class=\"heading-number\">1.</span> First", 2, "first"),
                         Govspeak::Header.new("<span class=\"heading-number\">2.</span> Second", 2, "second")]

    assert_equal expected_headings, html_attachment_govspeak_headers(attachment)
  end

  test "#html_attachment_govspeak_headers_html renders an <ol>" do
    attachment = build(
      :html_attachment,
      body: "## 1. First\n\n## 2. Second\n\n### 2.1 Sub",
      manually_numbered_headings: true
    )
    expected = <<-HTML
      <ol class=\"unnumbered\">
        <li class=\"numbered\">
          <a href=\"#first\"><span class=\"heading-number\">1.</span> First</a>
        </li>
        <li class=\"numbered\">
          <a href=\"#second\"><span class=\"heading-number\">2.</span> Second</a>
        </li>
      </ol>
    HTML

    rendered_attachment_headers = html_attachment_govspeak_headers_html(attachment)
    assert_equivalent_html expected, rendered_attachment_headers
  end


  test "#html_attachment_govspeak_headers_html correctly renders links to overridden header ids" do
    attachment = build(
      :html_attachment,
      body: "## First\n{:#overridden-first}\n\n## Second\n{:#overridden-second}\n\n## Third\n{:#overridden-third}",
      manually_numbered_headings: true
    )
    expected = <<-HTML
      <ol class=\"unnumbered\">
        <li>
          <a href=\"#overridden-first\">First</a>
        </li>
        <li>
          <a href=\"#overridden-second\">Second</a>
        </li>
        <li>
          <a href=\"#overridden-third\">Third</a>
        </li>
      </ol>
    HTML

    rendered_attachment_headers = html_attachment_govspeak_headers_html(attachment)
    assert_equivalent_html expected, rendered_attachment_headers
  end

  test "should raise exception when extracting header hierarchy with orphaned level 3 headings" do
    e = assert_raise(OrphanedHeadingError) { govspeak_header_hierarchy("### Heading 3") }
    assert_equal "Heading 3", e.heading
  end

  test "should convert single document to govspeak" do
    document = build(:published_publication, body: "## test")
    html = govspeak_edition_to_html(document)
    assert_select_within_html html, "h2"
  end

  test "should return an empty string if nil edition" do
    assert_equal '', govspeak_edition_to_html(nil)
  end

  test "should optionally not wrap output in a govspeak class" do
    document = build(:published_publication, body: "govspeak-text")
    html = bare_govspeak_edition_to_html(document)
    assert_select_within_html html, ".govspeak", false
    assert_select_within_html html, "p", "govspeak-text"
  end

  test "should add block attachments inline" do
    text = "#Heading\n\n!@1\n\n##Subheading"
    document = build(:published_detailed_guide, :with_file_attachment, body: text)
    html = govspeak_edition_to_html(document)
    assert_select_within_html html, "h1"
    assert_select_within_html html, ".attachment.embedded"
    assert_select_within_html html, "h2"
  end

  test "should add inline attachments inline" do
    text = "#Heading\n\nText about my [InlineAttachment:1]."
    document = build(:published_detailed_guide, :with_file_attachment, body: text)
    html = govspeak_edition_to_html(document)
    assert_select_within_html html, "h1"
    assert_select_within_html html, ".attachment-inline"
  end

  test "should ignore missing block attachments" do
    text = "#Heading\n\n!@2\n\n##Subheading"
    document = build(:published_detailed_guide, :with_file_attachment, body: text)
    html = govspeak_edition_to_html(document)
    assert_select_within_html html, "h1"
    refute_select_within_html html, ".attachment.embedded"
    assert_select_within_html html, "h2"
  end

  test "should ignore missing inline attachments" do
    text = "#Heading\n\nText about my [InlineAttachment:2]."
    document = build(:published_detailed_guide, :with_file_attachment, body: text)
    html = govspeak_edition_to_html(document)
    assert_select_within_html html, "h1"
    refute_select_within_html html, ".attachment-inline"
  end

  test "should not convert documents with no block attachments" do
    text = "#Heading\n\n!@2"
    document = build(:published_detailed_guide, body: text)
    html = govspeak_edition_to_html(document)
    refute_select_within_html html, ".attachment.embedded"
  end

  test "should not convert documents with no inline attachments" do
    text = "#Heading\n\nText about my [InlineAttachment:2]."
    document = build(:published_detailed_guide, body: text)
    html = govspeak_edition_to_html(document)
    refute_select_within_html html, ".attachment-inline"
  end

  test "should convert multiple block attachments" do
    text = "#heading\n\n!@1\n\n!@2"
    document = build(:published_detailed_guide, :with_file_attachment, body: text, attachments: [
      attachment_1 = build(:file_attachment, id: 1),
      attachment_2 = build(:file_attachment, id: 2)
    ])
    html = govspeak_edition_to_html(document)
    assert_select_within_html html, "#attachment_#{attachment_1.id}"
    assert_select_within_html html, "#attachment_#{attachment_2.id}"
  end

  test "should convert multiple inline attachments" do
    text = "#Heading\n\nText about my [InlineAttachment:2] and [InlineAttachment:1]."
    document = build(:published_detailed_guide, :with_file_attachment, body: text, attachments: [
      attachment_1 = build(:file_attachment, id: 1),
      attachment_2 = build(:file_attachment, id: 2)
    ])
    html = govspeak_edition_to_html(document)
    assert_select_within_html html, "#attachment_#{attachment_1.id}"
    assert_select_within_html html, "#attachment_#{attachment_2.id}"
  end

  test "should not escape embedded attachment when attachment embed code only separated by one newline from a previous paragraph" do
    text = "para\n!@1"
    document = build(:published_detailed_guide, :with_file_attachment, body: text)
    html = govspeak_edition_to_html(document)
    assert_not html.include?("&lt;div"), "should not escape embedded attachment"
    assert_select_within_html html, ".attachment.embedded"
  end

  test "embeds image urls" do
    edition = build(:published_news_article, body: "!!1")
    edition.stubs(:images).returns([OpenStruct.new(alt_text: "My Alt", url: "https://some.cdn.com/image.jpg")])
    html = govspeak_edition_to_html(edition)
    assert_select_within_html html, ".govspeak figure.image.embedded img[src='https://some.cdn.com/image.jpg']"
  end

  test "does not prefix embedded attachment urls with asset host so that access to them can be authenticated when previewing draft documents" do
    Whitehall.stubs(:public_asset_host).returns("https://some.cdn.com")
    edition = build(:published_publication, :with_file_attachment, body: "!@1")
    html = govspeak_edition_to_html(edition)
    assert_select_within_html html, ".govspeak .attachment.embedded a[href^='/'][href$='greenpaper.pdf']"
  end

  test "should remove extra quotes from blockquote text" do
    remover = stub("remover");
    remover.expects(:remove).returns("remover return value")
    Whitehall::ExtraQuoteRemover.stubs(:new).returns(remover)
    edition = build(:published_publication, body: %{He said:\n> "I'm not sure what you mean!"\nOr so we thought.})
    assert_match %r[remover return value], govspeak_edition_to_html(edition)
  end

  test "should add class to last paragraph of blockquote" do
    input = "\n> firstline\n>\n> lastline\n"
    output = '<div class="govspeak"> <blockquote> <p>firstline</p> <p class="last-child">lastline</p> </blockquote></div>'
    assert_equivalent_html output, govspeak_to_html(input).gsub(/\s+/, ' ')
  end

  test "adds numbers to h2 headings" do
    input = "# main\n\n## first\n\n## second"
    output = '<div class="govspeak"><h1 id="main">main</h1> <h2 id="first"> <span class="number">1. </span>first</h2> <h2 id="second"> <span class="number">2. </span>second</h2></div>'
    assert_equivalent_html output, govspeak_to_html(input, [], heading_numbering: :auto).gsub(/\s+/, ' ')
  end

  test "adds sub-numbers to h3 tags" do
    input = "## first\n\n### first point one\n\n### first point two\n\n## second\n\n### second point one"
    expected_output_1 = '<h2 id="first"> <span class="number">1. </span>first</h2>'
    expected_output_1_1 = '<h3 id="first-point-one"> <span class="number">1.1 </span>first point one</h3>'
    expected_output_1_2 = '<h3 id="first-point-two"> <span class="number">1.2 </span>first point two</h3>'
    expected_output_2 = '<h2 id="second"> <span class="number">2. </span>second</h2>'
    expected_output_2_1 = '<h3 id="second-point-one"> <span class="number">2.1 </span>second point one</h3>'
    actual_output = govspeak_to_html(input, [], heading_numbering: :auto).gsub(/\s+/, ' ')
    assert_match %r(#{expected_output_1}), actual_output
    assert_match %r(#{expected_output_1_1}), actual_output
    assert_match %r(#{expected_output_1_2}), actual_output
    assert_match %r(#{expected_output_2}), actual_output
    assert_match %r(#{expected_output_2_1}), actual_output
  end

  test "adds manual numbering to heading tags" do
    input = "## 1. Main\n\n## 2. Second\n\n### Sub heading without a number\n\n## 42.12 Out of sequence"
    expected_output = '<div class="govspeak"><h2 id="main"> <span class="number">1. </span> Main</h2> <h2 id="second"> <span class="number">2. </span> Second</h2> <h3 id="sub-heading-without-a-number">Sub heading without a number</h3> <h2 id="out-of-sequence"> <span class="number">42.12 </span> Out of sequence</h2></div>'
    assert_equivalent_html expected_output, govspeak_to_html(input, [], heading_numbering: :manual).gsub(/\s+/, ' ')
  end

  test "leaves heading numbers not occuring at the start of the heading text alone when using manual heading numbering" do
    input = "## Number 8"
    result = Nokogiri::HTML::DocumentFragment.parse(govspeak_to_html(input, [], heading_numbering: :manual))
    assert_equal "Number 8", result.css('h2').first.text
  end

  test "should not corrupt character encoding of numbered headings" do
    input = '# café'
    actual_output = govspeak_to_html(input, [], heading_numbering: :auto)
    assert actual_output.include?('café</h1>')
  end

  test 'converts [Contact:<id>] into a rendering of contacts/_contact for the Contact with id = <id>' do
    contact = build(:contact)
    Contact.stubs(:find_by).with(id: '1').returns(contact)
    input = '[Contact:1]'
    output = govspeak_to_html(input)
    contact_html = render('contacts/contact', contact: contact, heading_tag: 'h3')
    assert_equivalent_html "<div class=\"govspeak\">#{contact_html}</div>", output
  end

  test 'converts [Contact:<id>] into a rendering of contacts/_contact for the Contact with id = <id> with defined header level' do
    contact = build(:contact)
    Contact.stubs(:find_by).with(id: '1').returns(contact)
    input = '[Contact:1]'
    output = govspeak_to_html(input, [], contact_heading_tag: 'h4')
    contact_html = render('contacts/contact', contact: contact, heading_tag: 'h4')
    assert_equivalent_html "<div class=\"govspeak\">#{contact_html}</div>", output
  end

  test 'silently converts [Contact:<id>] into nothing if there is no Contact with id = <id>' do
    Contact.stubs(:find_by).with(id: '1').returns(nil)
    input = '[Contact:1]'
    output = govspeak_to_html(input)
    assert_equivalent_html "<div class=\"govspeak\"></div>", output
  end

  test 'will use the html version of the contact partial, even if the view context is for a different format' do
    contact = build(:contact)
    Contact.stubs(:find_by).with(id: '1').returns(contact)
    input = '[Contact:1]'
    contact_html = render('contacts/contact', contact: contact, heading_tag: 'h3')
    @controller.lookup_context.formats = %w[atom]
    assert_nothing_raised do
      assert_equivalent_html "<div class=\"govspeak\">#{contact_html}</div>", govspeak_to_html(input)
    end
  end

  test 'will add a barchart class to a marked table' do
    input = <<~INPUT
      |col|
      |---|
      |val|
      {barchart}
    INPUT
    html = govspeak_to_html(input)
    assert_select_within_html html, "table.js-barchart-table"
  end

  test 'will add a stacked, compact, negative barchart class to a marked table' do
    input = <<~INPUT
      |col|
      |---|
      |val|
      {barchart stacked compact negative}
    INPUT
    html = govspeak_to_html(input)
    assert_select_within_html html, "table.mc-stacked.js-barchart-table.mc-negative.compact"
  end

  test 'will make a marked table sortable' do
    input = <<~INPUT
      |col|
      |---|
      |val|
      {sortable}
    INPUT
    html = govspeak_to_html(input)
    assert_select_within_html html, "table.sortable"
  end

  test 'will make a marked table sortable and a barchart' do
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
    path   = "#{Whitehall.public_asset_host}#{prefix}/fractions/1_2.png"
    html   = govspeak_to_html("I'm [Fraction:1/2] a person")

    assert_select_within_html(html, "img[src='#{path}']")
  end

  test 'will create bespoke fractions' do
    input = "Some text [Fraction:1/72] and some text"
    html = govspeak_to_html(input)
    assert_select_within_html html, "span.fraction > sup", text: '1'
    assert_select_within_html html, "span.fraction > sub", text: '72'
  end

  test 'will create fractions using images for a known set' do
    input = "Some text [Fraction:1/4] and some text"
    html = govspeak_to_html(input)
    assert_select_within_html html, "span.fraction > img[alt='1/4']"
  end

  test 'will create algebraic and trigonometric fractions using images for a known set' do
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

  test 'govspeak_with_attachments_and_alt_format_information' do
    body = "#Heading\n\n!@1\n\n##Subheading"
    document = build(:published_detailed_guide, :with_file_attachment, body: body)
    attachments = document.attachments
    html = govspeak_with_attachments_to_html(body, attachments, 'batman@wayne.technology')
    assert html.include? '>batman@wayne.technology</a>'
  end
end
