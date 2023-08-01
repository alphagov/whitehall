class SpecialRoute
  def self.all
    [
      {
        base_path: "/government",
        content_id: "4672b1ff-f147-4d49-a5f4-4959588da5a8",
        title: "Government prefix",
        description: "The prefix route under which almost all government content is published.",
      },
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
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        document_type: "get_involved",
        schema_name: "get_involved",
      },
      {
        base_path: "/api/governments",
        content_id: "2d5bafcc-2c45-4a84-8fbc-525b75dd6d19",
        title: "Governments API",
        description: "API exposing all governments on GOV.UK.",
      },
      {
        base_path: "/api/world-locations",
        content_id: "2a63b605-77be-4af5-932d-224a054dd5a5",
        title: "World Locations API",
        description: "API exposing all world locations on GOV.UK.",
      },
      {
        base_path: "/api/worldwide-organisations",
        content_id: "736f8a5a-ce6f-4a6f-b0cb-954442aa23c1",
        title: "Worldwide Organisations API",
        description: "API exposing all worldwide organisations on GOV.UK.",
      },
    ]
  end
end
