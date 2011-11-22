require 'test_helper'

class GovspeakHelperTest < ActionView::TestCase
  include AdminDocumentRoutesHelper
  include PublicDocumentRoutesHelper

  setup do
    @request  = ActionController::TestRequest.new
  end
  attr_reader :request

  test "should mark the admin govspeak output as html safe" do
    html = govspeak_to_admin_html("govspeak-text")
    assert html.html_safe?
  end

  test "should not alter urls to other sites in the admin preview" do
    html = govspeak_to_admin_html("no [change](http://external.example.com/page.html)")
    assert_equal %{<p>no <a href="http://external.example.com/page.html">change</a></p>}, html.strip
  end

  test "should not alter urls to other sites" do
    html = govspeak_to_html("no [change](http://external.example.com/page.html)")
    assert_equal %{<p>no <a href="http://external.example.com/page.html">change</a></p>}, html.strip
  end

  test "should not alter mailto urls in the admin preview" do
    html = govspeak_to_admin_html("no [change](mailto:dave@example.com)")
    assert_equal %{<p>no <a href="mailto:dave@example.com">change</a></p>}, html.strip
  end

  test "should not alter mailto urls" do
    html = govspeak_to_html("no [change](mailto:dave@example.com)")
    assert_equal %{<p>no <a href="mailto:dave@example.com">change</a></p>}, html.strip
  end

  test "should highlight links to draft documents in admin preview" do
    publication = create(:draft_publication)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url(publication)})")
    assert_equal %{<p>this and <span class="draft_link"><a href="#{admin_publication_url(publication)}">that</a> <sup class="explanation">(draft)</sup></span></p>}, html.strip
  end

  test "should highlight links to deleted documents in admin preview" do
    publication = create(:deleted_publication)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url(publication)})")
    assert_equal %{<p>this and <span class="deleted_link"><del>that</del> <sup class="explanation">(deleted)</sup></span></p>}, html.strip
  end

  test "should highlight links to destroyed supporting documents in admin preview" do
    html = govspeak_to_admin_html("this and [that](#{admin_supporting_document_url("missing-id")})")
    assert_equal %{<p>this and <span class="deleted_link"><del>that</del> <sup class="explanation">(deleted)</sup></span></p>}, html.strip
  end

  test "should highlight links to published documents in admin preview" do
    publication = create(:published_publication)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_url(publication)})")
    assert_equal %{<p>this and <span class="published_link"><a href="#{admin_publication_url(publication)}">that</a> <sup class="explanation">(<a class="public_link" href="#{public_document_path(publication)}">public link</a>)</sup></span></p>}, html.strip
  end

  test "should mark the govspeak output as html safe" do
    html = govspeak_to_html("govspeak-text")
    assert html.html_safe?
  end

  test "should not link to draft documents" do
    publication = create(:draft_publication)
    html = govspeak_to_html("this and [that](#{admin_publication_url(publication)})")
    assert_equal "<p>this and that</p>", html.strip
  end

  test "should not link to deleted documents" do
    publication = create(:deleted_publication)
    html = govspeak_to_html("this and [that](#{admin_publication_url(publication)})")
    assert_equal "<p>this and that</p>", html.strip
  end

  [Policy, Publication, NewsArticle, Consultation].each do |document_class|
    test "should rewrite absolute links to admin previews of #{document_class.name} as their public document identity" do
      document = create(:"published_#{document_class.name.underscore}")
      html = govspeak_to_html("this and [that](http://test.host#{admin_document_path(document)}) yeah?")
      assert_equal %{<p>this and <a href="#{public_document_path(document)}">that</a> yeah?</p>}, html.strip
    end
  end

  test "should rewrite absolute links to admin previews of Speeches as their public document identity" do
    speech = create(:published_speech)
    public_path = public_document_path(speech.becomes(Speech))
    html = govspeak_to_html("this and [that](#{admin_speech_url(speech)}) yeah?")
    assert_equal %{<p>this and <a href="#{public_path}">that</a> yeah?</p>}, html.strip
  end

  test "should rewrite absolute links to admin previews of SupportingDocuments as their public document identity" do
    policy = create(:published_policy)
    supporting_document = create(:supporting_document, document: policy)
    html = govspeak_to_html("this and [that](#{admin_supporting_document_url(supporting_document)}) yeah?")
    assert_equal %{<p>this and <a href="#{policy_supporting_document_path(policy, supporting_document)}">that</a> yeah?</p>}, html.strip
  end

  test "should not link to SupportingDocuments whose documents are not published" do
    policy = create(:draft_policy)
    supporting_document = create(:supporting_document, document: policy)
    html = govspeak_to_html("this and [that](http://test.host#{admin_supporting_document_path(supporting_document)}) yeah?")
    assert_equal %{<p>this and that yeah?</p>}, html.strip
  end

end