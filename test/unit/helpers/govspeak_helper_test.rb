# encoding: UTF-8
require 'test_helper'

class GovspeakHelperTest < ActionView::TestCase
  include AdminDocumentRoutesHelper
  include PublicDocumentRoutesHelper

  setup do
    @request  = ActionController::TestRequest.new
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

  test "should highlight links to draft documents in admin preview" do
    publication = create(:draft_publication)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url(publication)})")
    assert_govspeak %{<p>this and <span class="draft_link"><a href="#{admin_publication_url(publication)}">that</a> <sup class="explanation">(draft)</sup></span></p>}, html
  end

  test "should replace links using Nokogiri::HTML.fragment to protect unicode" do
    publication = create(:draft_publication)
    govspeak_processed_text = %{<p>this and <a href=\'#{admin_publication_url(publication)}\'>that&rsquo; nice</a></p>\n}
    fragment_to_be_returned = Nokogiri::HTML.fragment(govspeak_processed_text)
    Nokogiri::HTML.stubs(:fragment).with(anything).returns(fragment_to_be_returned)

    expected_html = %{<span class="draft_link"><a href="#{admin_publication_url(publication)}">that’ nice</a> <sup class="explanation">(draft)</sup></span>}
    Nokogiri::HTML.expects(:fragment).with(expected_html).returns("anything")

    govspeak_to_admin_html("this and [that' nice](#{admin_publication_url(publication)})")
  end

  test "should highlight links to deleted documents in admin preview" do
    publication = create(:deleted_publication)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url(publication)})")
    assert_govspeak %{<p>this and <span class="deleted_link"><del>that</del> <sup class="explanation">(deleted)</sup></span></p>}, html
  end

  test "should highlight links to missing documents in admin preview" do
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url('missing-id')})")
    assert_govspeak %{<p>this and <span class="deleted_link"><del>that</del> <sup class="explanation">(deleted)</sup></span></p>}, html
  end

  test "should highlight links to destroyed supporting pages in admin preview" do
    html = govspeak_to_admin_html("this and [that](#{admin_supporting_page_url("missing-id")})")
    assert_govspeak %{<p>this and <span class="deleted_link"><del>that</del> <sup class="explanation">(deleted)</sup></span></p>}, html
  end

  test "should highlight links to published documents in admin preview" do
    publication = create(:published_publication)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url(publication)})")
    assert_govspeak %{<p>this and <span class="published_link"><a href="#{admin_publication_url(publication)}">that</a> <sup class="explanation">(<a class="public_link" href="#{public_document_path(publication)}">public link</a>)</sup></span></p>}, html
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

  test "should not link to draft documents" do
    publication = create(:draft_publication)
    html = govspeak_to_html("this and [that](#{admin_publication_url(publication)})")
    assert_govspeak "<p>this and that</p>", html
  end

  test "should not link to deleted documents" do
    publication = create(:deleted_publication)
    html = govspeak_to_html("this and [that](#{admin_publication_url(publication)})")
    assert_govspeak "<p>this and that</p>", html
  end

  [Policy, Publication, NewsArticle, Consultation].each do |document_class|
    test "should rewrite absolute links to admin previews of #{document_class.name} as their public document identity" do
      document = create(:"published_#{document_class.name.underscore}")
      html = govspeak_to_html("this and [that](http://test.host#{admin_document_path(document)}) yeah?")
      assert_govspeak %{<p>this and <a href="#{public_document_path(document)}">that</a> yeah?</p>}, html
    end
  end

  test "should rewrite absolute links to admin previews of Speeches as their public document identity" do
    speech = create(:published_speech)
    public_path = public_document_path(speech)
    html = govspeak_to_html("this and [that](#{admin_speech_url(speech)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{public_path}">that</a> yeah?</p>}, html
  end

  test "should rewrite absolute links to admin previews of SupportingPages as their public document identity" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, document: policy)
    html = govspeak_to_html("this and [that](#{admin_supporting_page_url(supporting_page)}) yeah?")
    assert_govspeak %{<p>this and <a href="#{policy_supporting_page_path(policy, supporting_page)}">that</a> yeah?</p>}, html
  end

  test "should not link to SupportingPages whose documents are not published" do
    policy = create(:draft_policy)
    supporting_page = create(:supporting_page, document: policy)
    html = govspeak_to_html("this and [that](http://test.host#{admin_supporting_page_path(supporting_page)}) yeah?")
    assert_govspeak %{<p>this and that yeah?</p>}, html
  end

  private

  def assert_govspeak(expected, actual)
    assert_equal %{<div class="govspeak">\n#{expected}\n</div>}, actual.strip
  end
end