module FilteringDocumentsHelper
  def assert_listed_document_count(expected_number)
    selector = 'ol.document-list li.document-row'

    assert page.has_css?(selector, count: expected_number),
      "Expected #{expected_number} document(s) to be listed, but #{page.all(selector).size} found instead"
  end

  def select_filter(label, value, opts = {})
    if opts[:and_clear_others]
      clear_filters
    end
    page.select value, from: label
    page.click_on "Refresh results"
  end

  def fill_in_filter(label, value, opts = {})
    if opts[:and_clear_others]
      clear_filters
    end
    page.fill_in label, with: value
    page.click_on "Refresh results"
  end

  def clear_filters
    within '#document-filter' do
      page.fill_in "Contains", with: ""
      page.select "All publication types", from: "Publication type" if page.has_selector?('label', text: "Publication type", wait: false)
      page.select "All policy areas", from: "Policy area"
      page.select "All departments", from: "Department"
      page.select "All documents", from: "Official document status" if page.has_selector?('label', text: "Official document status", wait: false)
      page.select "All locations", from: "World locations"
      page.fill_in "Published after", with: ""
      page.fill_in "Published before", with: ""
    end
  end
end

World(FilteringDocumentsHelper)
