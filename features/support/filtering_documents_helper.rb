module FilteringDocumentsHelper
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
      page.fill_in "Contains", with: ""                             if page.has_content?("Contains")
      page.select "All publication types", from: "Publication type" if page.has_content?("Publication type")
      page.select "All topics", from: "Topic"                       if page.has_content?("Topic")
      page.select "All departments", from: "Department"             if page.has_content?("Department")
      page.select "All documents", from: "Official document status" if page.has_content?("Official document status")
      page.select "All locations", from: "World locations"          if page.has_content?("World locations")
      page.fill_in "Published after", with: ""                      if page.has_content?("Published after")
      page.fill_in "Published before", with: ""                     if page.has_content?("Published before")
    end
  end
end

World(FilteringDocumentsHelper)
