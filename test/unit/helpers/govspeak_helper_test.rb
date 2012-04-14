# encoding: UTF-8
require 'test_helper'

class GovspeakHelperTest < ActionView::TestCase
  include Admin::DocumentRoutesHelper
  include PublicDocumentRoutesHelper

  setup do
    @request  = ActionController::TestRequest.new
    ActionController::Base.default_url_options = {}
  end
  attr_reader :request

  test "should wrap admin output with a govspeak class" do
    html = govspeak_to_admin_html("govspeak-text")
    assert_equal %{<div class="govspeak">\n<p>govspeak-text</p>\n</div>}, html.strip
  end

  test "should mark the admin govspeak output as html safe" do
    html = govspeak_to_admin_html("govspeak-text")
    assert html.html_safe?
  end

  test "should not alter urls to other sites in the admin preview" do
    html = govspeak_to_admin_html("no [change](http://external.example.com/page.html)")
    assert_govspeak %{<p>no <a href="http://external.example.com/page.html">change</a></p>}, html
  end

  test "should not alter urls to other sites" do
    html = govspeak_to_html("no [change](http://external.example.com/page.html)")
    assert_govspeak %{<p>no <a href="http://external.example.com/page.html">change</a></p>}, html
  end

  test "should not alter mailto urls in the admin preview" do
    html = govspeak_to_admin_html("no [change](mailto:dave@example.com)")
    assert_govspeak %{<p>no <a href="mailto:dave@example.com">change</a></p>}, html
  end

  test "should not alter mailto urls" do
    html = govspeak_to_html("no [change](mailto:dave@example.com)")
    assert_govspeak %{<p>no <a href="mailto:dave@example.com">change</a></p>}, html
  end

  test "should not alter invalid urls" do
    html = govspeak_to_html("no [change](not a valid url)")
    assert_govspeak %{<p>no <a href="not%20a%20valid%20url">change</a></p>}, html
  end

  test "should not alter partial urls in the admin preview" do
    html = govspeak_to_admin_html("no [change](http://)")
    assert_govspeak %{<p>no <a href="http://">change</a></p>}, html
  end

  test "should not alter partial urls" do
    html = govspeak_to_html("no [change](http://)")
    assert_govspeak %{<p>no <a href="http://">change</a></p>}, html
  end

  test "should rewrite link to draft document in admin preview" do
    publication = create(:draft_publication)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url(publication)})")
    assert_govspeak %{<p>this and <span class="draft_link">that <sup class="explanation">(<a href="#{admin_publication_path(publication)}">draft</a>)</sup></span></p>}, html
  end

  test "should not alter unicode when replacing links" do
    publication = create(:published_publication)
    html = govspeak_to_admin_html("the [☃](#{admin_publication_url(publication)})")
    assert_govspeak %{<p>the <span class="published_link"><a href="#{public_document_path(publication)}">☃</a> <sup class="explanation">(<a href="#{admin_publication_path(publication)}">published</a>)</sup></span></p>}, html
  end

  test "should rewrite link to deleted document in admin preview" do
    publication = create(:deleted_publication)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url(publication)})")
    assert_govspeak %{<p>this and <span class="deleted_link"><del>that</del> <sup class="explanation">(deleted)</sup></span></p>}, html
  end

  test "should rewrite link to missing document in admin preview" do
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url('missing-id')})")
    assert_govspeak %{<p>this and <span class="deleted_link"><del>that</del> <sup class="explanation">(deleted)</sup></span></p>}, html
  end

  test "should rewrite link to destroyed supporting page in admin preview" do
    html = govspeak_to_admin_html("this and [that](#{admin_document_supporting_page_url("doesnt-exist", "missing-id")})")
    assert_govspeak %{<p>this and <span class="deleted_link"><del>that</del> <sup class="explanation">(deleted)</sup></span></p>}, html
  end

  test "should rewrite link to published document in admin preview" do
    publication = create(:published_publication)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url(publication)})")
    assert_govspeak %{<p>this and <span class="published_link"><a href="#{public_document_path(publication)}">that</a> <sup class="explanation">(<a href="#{admin_publication_path(publication)}">published</a>)</sup></span></p>}, html
  end

  test "should rewrite link to published document with a newer draft in admin preview" do
    publication = create(:published_publication)
    new_draft = publication.create_draft(create(:policy_writer))
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url(publication)})")
    assert_govspeak %{<p>this and <span class="draft_link"><a href="#{public_document_path(publication)}">that</a> <sup class="explanation">(<a href="#{admin_publication_path(new_draft)}">draft</a>)</sup></span></p>}, html
  end

  test "should rewrite link to archived document with a newer published edition in admin preview" do
    publication = create(:published_publication)
    writer = create(:policy_writer)
    editor = create(:departmental_editor)
    new_edition = publication.create_draft(writer)
    new_edition.change_note = "change-note"
    new_edition.save_as(writer)
    new_edition.submit!
    new_edition.publish_as(editor)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url(publication)})")
    assert_govspeak %{<p>this and <span class="published_link"><a href="#{public_document_path(publication)}">that</a> <sup class="explanation">(<a href="#{admin_publication_path(new_edition)}">published</a>)</sup></span></p>}, html
  end

  test "should rewrite link to deleted document with an older published edition in admin preview" do
    publication = create(:published_publication)
    new_draft = publication.create_draft(create(:policy_writer))
    new_draft.delete!
    deleted_edition = new_draft
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url(deleted_edition)})")
    assert_govspeak %{<p>this and <span class="published_link"><a href="#{public_document_path(publication)}">that</a> <sup class="explanation">(<a href="#{admin_publication_path(publication)}">published</a>)</sup></span></p>}, html
  end

  test "should allow attached images to be embedded in admin html" do
    images = [OpenStruct.new(alt_text: "My Alt", url: "http://example.com/image.jpg")]
    html = govspeak_to_admin_html("!!1", images)
    assert_govspeak_by_css_selector '.govspeak figure.image.embedded img', html
  end

  # public govspeak helper tests

  test "should wrap output with a govspeak class" do
    html = govspeak_to_html("govspeak-text")
    assert_equal %{<div class="govspeak">\n<p>govspeak-text</p>\n</div>}, html.strip
  end

  test "should mark the govspeak output as html safe" do
    html = govspeak_to_html("govspeak-text")
    assert html.html_safe?
  end

  test "should produce UTF-8 for HTML entities" do
    html = govspeak_to_html("a ['funny'](/url) thing")
    assert_govspeak %{<p>a <a href="/url">‘funny’</a> thing</p>}, html
  end

  test "should not link to draft documents with no published edition" do
    publication = create(:draft_publication)
    html = govspeak_to_html("this and [that](#{admin_publication_url(publication)})")
    assert_govspeak "<p>this and that</p>", html
  end

  test "should not link to deleted documents with no published edition" do
    publication = create(:deleted_publication)
    html = govspeak_to_html("this and [that](#{admin_publication_url(publication)})")
    assert_govspeak "<p>this and that</p>", html
  end

  [Policy, Publication, NewsArticle, Consultation].each do |document_class|
    test "should rewrite absolute links to admin previews of published #{document_class.name} as their public doc identity" do
      document = create(:"published_#{document_class.name.underscore}")
      html = govspeak_to_html("this and [that](http://test.host#{admin_document_path(document)}) yeah?")
      assert_govspeak %{<p>this and <a href="#{public_document_path(document)}">that</a> yeah?</p>}, html
    end
  end

  test "should rewrite absolute links to admin previews of published Speeches as their public doc identity" do
    speech = create(:published_speech)
    public_path = public_document_path(speech)
    html = govspeak_to_html("this and [that](#{admin_speech_url(speech)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{public_path}">that</a> yeah?</p>}, html
  end

  test "should rewrite absolute links to admin previews of published SupportingPages as their public doc identity" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, document: policy)
    html = govspeak_to_html("this and [that](#{admin_supporting_page_url(supporting_page)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{public_supporting_page_path(policy, supporting_page)}">that</a> yeah?</p>}, html
  end

  test 'should rewrite admin link to an archived document with a published edition' do
    document = create(:published_policy)
    writer = create(:policy_writer)
    editor = create(:departmental_editor)
    new_draft = document.create_draft(writer)
    new_draft.save_as(writer)
    new_draft.submit!
    new_draft.publish_as(editor)

    html = govspeak_to_html("this and [that](http://test.host#{admin_document_path(document)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{public_document_path(document)}">that</a> yeah?</p>}, html
  end

  test 'should rewrite admin link to a draft document with a published edition' do
    document = create(:published_policy)
    writer = create(:policy_writer)
    new_draft = document.create_draft(writer)
    new_draft.save_as(writer)

    html = govspeak_to_html("this and [that](http://test.host#{admin_document_path(new_draft)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{public_document_path(document)}">that</a> yeah?</p>}, html
  end

  test "should rewrite absolute links to admin previews of Speeches as their public doc identity on preview" do
    request.host = ActionController::Base.default_url_options[:host] = "whitehall.preview.alphagov.co.uk"
    speech = create(:published_speech)
    public_url = public_document_url(speech)
    html = govspeak_to_html("this and [that](#{admin_speech_url(speech)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{public_url}">that</a> yeah?</p>}, html
  end

  test "should rewrite absolute links to admin previews of Speeches as their public doc identity on public preview" do
    request.host = "www.preview.alphagov.co.uk"
    ActionController::Base.default_url_options[:host] = "whitehall.preview.alphagov.co.uk"
    speech = create(:published_speech)
    public_url = public_document_url(speech)
    html = govspeak_to_html("this and [that](#{admin_speech_url(speech)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{public_url}">that</a> yeah?</p>}, html
  end

  test "should rewrite absolute links to admin previews of SupportingPages as their public doc identity on preview" do
    request.host = ActionController::Base.default_url_options[:host] = "whitehall.preview.alphagov.co.uk"
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, document: policy)
    html = govspeak_to_html("this and [that](#{admin_supporting_page_url(supporting_page)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{public_supporting_page_url(policy, supporting_page, host: "www.preview.alphagov.co.uk")}">that</a> yeah?</p>}, html
  end

  test "should rewrite absolute links to admin previews of SupportingPages as their public doc identity on public preview" do
    request.host ="www.preview.alphagov.co.uk"
    ActionController::Base.default_url_options[:host] = "whitehall.preview.alphagov.co.uk"
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, document: policy)
    html = govspeak_to_html("this and [that](#{admin_supporting_page_url(supporting_page)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{public_supporting_page_url(policy, supporting_page, host: "www.preview.alphagov.co.uk")}">that</a> yeah?</p>}, html
  end

  test "should rewrite absolute links to admin previews of Speeches as their public doc identity on production" do
    request.host = ActionController::Base.default_url_options[:host] = "whitehall.production.alphagov.co.uk"
    speech = create(:published_speech)
    public_url = public_document_url(speech)
    html = govspeak_to_html("this and [that](#{admin_speech_url(speech)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{public_url}">that</a> yeah?</p>}, html
  end

  test "should rewrite absolute links to admin previews of Speeches as their public doc identity on public production" do
    request.host = "www.gov.uk"
    ActionController::Base.default_url_options[:host] = "whitehall.production.alphagov.co.uk"
    speech = create(:published_speech)
    public_url = public_document_url(speech)
    html = govspeak_to_html("this and [that](#{admin_speech_url(speech)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{public_url}">that</a> yeah?</p>}, html
  end

  test "should rewrite absolute links to admin previews of SupportingPages as their public doc identity on production" do
    request.host = ActionController::Base.default_url_options[:host] = "whitehall.production.alphagov.co.uk"
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, document: policy)
    html = govspeak_to_html("this and [that](#{admin_supporting_page_url(supporting_page)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{public_supporting_page_url(policy, supporting_page, host: "www.gov.uk")}">that</a> yeah?</p>}, html
  end

  test "should rewrite absolute links to admin previews of SupportingPages as their public doc identity on public production" do
    request.host = "www.gov.uk"
    ActionController::Base.default_url_options[:host] = "whitehall.production.alphagov.co.uk"
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, document: policy)
    html = govspeak_to_html("this and [that](#{admin_supporting_page_url(supporting_page)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{public_supporting_page_url(policy, supporting_page, host: "www.gov.uk")}">that</a> yeah?</p>}, html
  end

  test "should not link to SupportingPages whose documents are not published" do
    policy = create(:draft_policy)
    supporting_page = create(:supporting_page, document: policy)
    html = govspeak_to_html("this and [that](http://test.host#{admin_supporting_page_path(supporting_page)}) yeah?")
    assert_govspeak %{<p>this and that yeah?</p>}, html
  end

  test "should allow attached images to be embedded in public html" do
    images = [OpenStruct.new(alt_text: "My Alt", url: "http://example.com/image.jpg")]
    html = govspeak_to_html("!!1", images)
    assert_govspeak_by_css_selector '.govspeak figure.image.embedded img', html
  end

  private

  def assert_govspeak(expected, actual)
    assert_equal %{<div class="govspeak">\n#{expected}\n</div>}, actual.strip
  end

  def assert_govspeak_by_css_selector(css_selector, actual, &block)
    doc = Nokogiri::HTML::Document.new
    doc.encoding = "UTF-8"
    fragment = doc.fragment(actual.strip)
    found = fragment.css(css_selector)
    if found.size > 0
      found.instance_eval(&block) if block_given?
    else
      fail "Expected to find '#{css_selector}', but not found in '#{actual}'"
    end
  end

end