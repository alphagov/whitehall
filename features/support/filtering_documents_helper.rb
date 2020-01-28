module FilteringDocumentsHelper
  def assert_listed_document_count(expected_number)
    selector = 'ol.document-list li.document-row'

    assert_selector selector, count: expected_number
  end

  def select_filter(label, value, opts = {})
    if opts[:and_clear_others]
      clear_filters
    end
    select value, from: label
    click_on "Refresh results"
  end

  def fill_in_filter(label, value, opts = {})
    if opts[:and_clear_others]
      clear_filters
    end
    fill_in label, with: value
    click_on "Refresh results"
  end

  def clear_filters
    within '#document-filter' do
      fill_in "Contains", with: ""
      select "All publication types", from: "Publication type" if has_selector?('label', text: "Publication type", wait: false)
      select "All topics", from: "Topic"
      select "All departments", from: "Department"
      select "All documents", from: "Official document status" if has_selector?('label', text: "Official document status", wait: false)
      select "All locations", from: "World locations"
      fill_in "Published after", with: ""
      fill_in "Published before", with: ""
    end
  end
end

World(FilteringDocumentsHelper)
