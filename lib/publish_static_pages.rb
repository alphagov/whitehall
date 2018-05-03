class PublishStaticPages
  def publish
    index = Whitehall::SearchIndex.for(:government)
    pages.each do |page|
      index.add(present_for_rummager(page)) unless page[:document_type] == "finder"

      payload = present_for_publishing_api(page)
      Services.publishing_api.put_content(payload[:content_id], payload[:content])
      Services.publishing_api.publish(payload[:content_id], nil, locale: "en")
    end
  end

  def patch_links(content_id, links)
    Services.publishing_api.patch_links(content_id, links)
  end

  def pages
    [
      {
        content_id: "f56cfe74-8e5c-432d-bfcf-fd2521c5919c",
        title: "How government works",
        document_type: "special_route",
        description: "About the UK system of government. Understand who runs government, and how government is run.",
        indexable_content: TemplateContent.new("home/how_government_works").indexable_content,
        base_path: "/government/how-government-works",
      },
      {
        content_id: "dbe329f1-359c-43f7-8944-580d4742aa91",
        title: "Get involved",
        document_type: "special_route",
        description: "Find out how you can engage with government directly, and take part locally, nationally or internationally.",
        indexable_content: TemplateContent.new("home/get_involved").indexable_content,
        base_path: "/government/get-involved",
      },
      {
        content_id: "db95a864-874f-4f50-a483-352a5bc7ba18",
        title: "History of the UK government",
        document_type: "special_route",
        description: "In this section you can read short biographies of notable people and explore the history of government buildings. You can also search our online records and read articles and blog posts by historians.",
        indexable_content: TemplateContent.new("histories/index").indexable_content,
        base_path: "/government/history",
      },
      {
        content_id: "14aa298f-03a8-4e76-96de-483efa3d001f",
        title: "History of 10 Downing Street",
        document_type: "special_route",
        description: "10 Downing Street, the locale of British prime ministers since 1735, vies with the White House as being the most important political building anywhere in the world in the modern era.",
        indexable_content: TemplateContent.new("histories/10_downing_street").indexable_content,
        base_path: "/government/history/10-downing-street",
      },
      {
        content_id: "7be62825-1538-4ff5-aa29-cd09350349f2",
        title: "History of 1 Horse Guards Road",
        document_type: "special_route",
        indexable_content: TemplateContent.new("histories/1_horse_guards_road").indexable_content,
        base_path: "/government/history/1-horse-guards-road",
      },
      {
        content_id: "9bdb6017-48c9-4590-b795-3c19d5e59320",
        title: "History of 11 Downing Street",
        document_type: "special_route",
        indexable_content: TemplateContent.new("histories/11_downing_street").indexable_content,
        base_path: "/government/history/11-downing-street",
      },
      {
        content_id: "bd216990-c550-4d28-ac05-649329298601",
        title: "History of King Charles Street (FCO)",
        document_type: "special_route",
        indexable_content: TemplateContent.new("histories/king_charles_street").indexable_content,
        base_path: "/government/history/king-charles-street",
      },
      {
        content_id: "60808448-769d-4915-981c-f34eb5f1b7bc",
        title: "History of Lancaster House (FCO)",
        document_type: "special_route",
        indexable_content: TemplateContent.new("histories/lancaster_house").indexable_content,
        base_path: "/government/history/lancaster-house",
      },
      {
        content_id: "b13317e9-3753-47b2-95da-c173071e621d",
        title: "All publications",
        document_type: "finder",
        description: "Find publications from across government including policy papers, consultations, statistics, research, transparency data and Freedom of Information responses.",
        base_path: "/government/publications",
      },
      {
        content_id: "a34e9bb6-f4af-4e4f-a21c-8127e3d2edbf",
        title: "Statistics",
        document_type: "finder",
        description: "Find statistics publications from across government, including statistical releases, live data tables, and National Statistics.",
        base_path: "/government/statistics",
        locales: Locale.non_english.map(&:code),
      },
      {
        content_id: "88936763-df8a-441f-8b96-9ea0dc0758a1",
        title: "Government announcements",
        document_type: "finder",
        description: "Find news articles, speeches and statements from government organisations",
        base_path: "/government/announcements",
        locales: Locale.non_english.map(&:code),
      },
      {
        content_id: "324e4708-2285-40a0-b3aa-cb13af14ec5f",
        title: "Ministers",
        document_type: "finder",
        description: "Read biographies and responsibilities of Cabinet ministers and all ministers by department, as well as the whips who help co-ordinate parliamentary business",
        base_path: "/government/ministers",
        locales: Locale.non_english.map(&:code),
      },
      {
        content_id: "430df081-f28e-4a1f-b812-8977fdac6e9a",
        title: "Find a British embassy, high commission or consulate",
        base_path: "/world/embassies",
        document_type: "finder",
        description: "Contact details of British embassies, consulates, high commissions around the world for help with visas, passports and more.",
      },
      {
        content_id: "fde62e52-dfb6-42ae-b336-2c4faf068101",
        title: "Departments, agencies and public bodies",
        base_path: "/government/organisations",
        document_type: "finder",
        description: "Information from government departments, agencies and public bodies, including news, campaigns, policies and contact details.",
        schema_name: "organisations_homepage",
      },
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
    routes_for_locales = (page[:locales] || []).map do |locale|
      { path: "#{page[:base_path]}.#{locale}", type: "exact" }
    end

    routes = [
      {
        path: page[:base_path],
        type: "exact",
      },
    ] + routes_for_locales

    {
      content_id: page[:content_id],
      content: {
        details: {},
        title: page[:title],
        description: page[:description],
        document_type: page[:document_type],
        schema_name: page.fetch(:schema_name, "placeholder"),
        locale: "en",
        base_path: page[:base_path],
        publishing_app: "whitehall",
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        routes: routes,
        public_updated_at: Time.zone.now.iso8601,
        update_type: "minor",
      }
    }
  end

  class TemplateContent
    include ActionView::Helpers::SanitizeHelper

    def initialize(template_path)
      @template_path = template_path
    end

    def indexable_content
      template = File.read("#{Rails.root}/app/views/#{@template_path}.html.erb")
      strip_tags(template)
    end
  end

  private_constant :TemplateContent
end
