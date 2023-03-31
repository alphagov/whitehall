class PublishStaticPages
  def publish
    index = Whitehall::SearchIndex.for(:government)
    pages.each do |page|
      index.add(present_for_rummager(page)) unless %w[finder history].include? page[:document_type]

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
        content_id: "dbe329f1-359c-43f7-8944-580d4742aa91",
        title: "Get involved",
        document_type: "get_involved",
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name: "get_involved",
        description: "Find out how you can engage with government directly, and take part locally, nationally or internationally.",
        base_path: "/government/get-involved",
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
        schema_name: "embassies_index",
        description: "Contact details of British embassies, consulates, high commissions around the world for help with visas, passports and more.",
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
        details: {
          body: page[:body],
        }.compact,
        title: page[:title],
        description: page[:description],
        document_type: page[:document_type],
        schema_name: (page[:schema_name] || "placeholder"),
        locale: "en",
        base_path: page[:base_path],
        publishing_app: "whitehall",
        rendering_app: page.fetch(:rendering_app, Whitehall::RenderingApp::WHITEHALL_FRONTEND),
        routes:,
        public_updated_at: Time.zone.now.iso8601,
        update_type: "minor",
      },
    }
  end

  class TemplateContent
    include ActionView::Helpers::SanitizeHelper

    def initialize(template_path)
      @template_path = template_path
    end

    def indexable_content
      template = File.read(Rails.root.join("app/views/#{@template_path}.html.erb"))
      strip_tags(template)
    end
  end

  private_constant :TemplateContent
end
