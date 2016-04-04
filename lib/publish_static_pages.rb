class PublishStaticPages
  def publish
    index = Whitehall::SearchIndex.for(:government)
    pages.each do |page|
      index.add(present_for_rummager(page))

      payload = present_for_publishing_api(page)
      publishing_api.put_content(payload[:content_id], payload[:content])
      publishing_api.publish(payload[:content_id], "minor", locale: "en")
    end
  end

  def patch_links(content_id, links)
    publishing_api.patch_links(content_id, links)
  end

  def pages
    [
      {
        content_id: "f56cfe74-8e5c-432d-bfcf-fd2521c5919c",
        title: "How government works",
        description: "About the UK system of government. Understand who runs government, and how government is run.",
        indexable_content: "government, parliament, coalition, civil service, civil servants, policies, policy, minister, ministers, MP, rt hon, right honourable, department, ndpb, agency, executive agency, agencies, organisation, public bodies, public body, FOI, freedom of information, transparency, democracy, westminster, whitehall, house of commons, house of lords",
        base_path: "/government/how-government-works",
      },
      {
        content_id: "dbe329f1-359c-43f7-8944-580d4742aa91",
        title: "Get involved",
        description: "Find out how you can engage with government directly, and take part locally, nationally or internationally.",
        indexable_content: "changing government policies, consultations, government departments",
        base_path: "/government/get-involved",
      }
    ]
  end

  def present_for_rummager(page)
    {
      _id: page[:base_path],
      link: page[:base_path],
      format: "edition", # Used for the rummager document type
      title: page[:title],
      description: page[:description],
      indexable_content: page[:indexable_content],
    }
  end

  def present_for_publishing_api(page)
    {
      content_id: page[:content_id],
      content: {
        title: page[:title],
        description: page[:description],
        format: "placeholder", # This content will never be rendered by content store
        locale: "en",
        base_path: page[:base_path],
        publishing_app: "whitehall",
        rendering_app: "whitehall",
        routes: [
          {
            path: page[:base_path],
            type: "exact",
          },
        ],
        public_updated_at: Time.zone.now.iso8601,
      }
    }
  end

private

  def publishing_api
    @publishing_api ||= Whitehall.publishing_api_v2_client
  end
end
