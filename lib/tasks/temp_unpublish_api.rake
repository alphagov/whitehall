desc "Manually unpublish content as gone"
task temp_unpublish_api: :environment do |_, _args|
  content_ids = %w[2a63b605-77be-4af5-932d-224a054dd5a5
                   2d5bafcc-2c45-4a84-8fbc-525b75dd6d19
                   736f8a5a-ce6f-4a6f-b0cb-954442aa23c1]

  content_ids.each do |content_id|
    Services.publishing_api.unpublish(
      content_id,
      type: "gone",
      locale: "en",
      explanation: "This API has been deprecated. See <a href=\"https://github.com/alphagov/govuk-rfcs/blob/main/rfc-159-switch-off-whitehall-apis.md\" class=\"govuk-link\">RFC-159</a>.",
    )

    puts "Unpublished #{content_id}"
  end
end
