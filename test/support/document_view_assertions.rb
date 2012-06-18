module DocumentViewAssertions
  def self.included(base)
    base.send(:include, PublicDocumentRoutesHelper)
    base.send(:include, ActionDispatch::Routing::UrlFor)
    base.send(:include, Rails.application.routes.url_helpers)
    base.default_url_options[:host] = 'www.example.com'
  end

  def assert_select_document_section_link(document, text, anchor)
    assert_select "ol#document_sections" do
      assert_select "li a[href='#{public_document_path(document, anchor: anchor)}']", text: text
    end
  end

  def refute_select_document_section_link(document, text, anchor)
    assert_select "ol#document_sections" do
      assert_select "li a[href='#{public_document_path(document, anchor: anchor)}']", text: text, count: 0
    end
  end

  def refute_select_document_section_list
    assert_select "ol#document_sections", count: 0
  end
end