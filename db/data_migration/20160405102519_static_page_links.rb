pages = [
  {
    content_id: "f56cfe74-8e5c-432d-bfcf-fd2521c5919c",
    links: {
      mainstream_browse_pages: [
        "abc8dd38-bbb7-40a9-b5a2-4b8a2b0db699", # citizenship/government
      ],
    }
  },
  {
    content_id: "dbe329f1-359c-43f7-8944-580d4742aa91",
    links: {
      mainstream_browse_pages: [
        "abc8dd38-bbb7-40a9-b5a2-4b8a2b0db699", # citizenship/government
        "7ef2c175-8a4b-4eb9-969b-304c6b9a1452", # citizenship/charities-honours
      ],
    }
  }
]

pages.each do |page|
  PublishStaticPages.new.patch_links(page[:content_id], links: page[:links])
end
