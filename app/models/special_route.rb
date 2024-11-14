class SpecialRoute
  def self.all
    [
      {
        base_path: "/government/feed",
        content_id: "725a346f-9e5b-486d-873d-2b050c126e09",
        title: "Government feed",
        description: "This route serves the feed of published content",
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
        type: "exact",
      },
      {
        base_path: "/government/get-involved",
        content_id: "dbe329f1-359c-43f7-8944-580d4742aa91",
        title: "Get involved",
        description: "Find out how you can engage with government directly, and take part locally, nationally or internationally.",
        rendering_app: Whitehall::RenderingApp::FRONTEND,
        document_type: "get_involved",
        schema_name: "get_involved",
      },
    ]
  end
end
