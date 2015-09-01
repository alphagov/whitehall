class PublishStaticPages
  def publish
    index = Whitehall::SearchIndex.for(:government)
    pages.each { |page| index.add(page) }
  end

private

  def pages
    [
      {
        _id: "/government/how-government-works",
        link: "/government/how-government-works",
        format: "edition",
        title: "How government works",
        description: "About the UK system of government. Understand who runs government, and how government is run.",
        indexable_content: "government, parliament, coalition, civil service, civil servants, policies, policy, minister, ministers, MP, rt hon, right honourable, department, ndpb, agency, executive agency, agencies, organisation, public bodies, public body, FOI, freedom of information, transparency, democracy, westminster, whitehall, house of commons, house of lords",
        mainstream_browse_pages: MainstreamBrowseTags.new('government/how-government-works').tags,
      },
      {
        _id: "/government/get-involved",
        link: "/government/get-involved",
        format: "edition",
        title: "Get involved",
        description: "Find out how you can engage with government directly, and take part locally, nationally or internationally.",
        indexable_content: "changing government policies, consultations, government departments",
        mainstream_browse_pages: MainstreamBrowseTags.new('government/get-involved').tags,
      }
    ]
  end
end
