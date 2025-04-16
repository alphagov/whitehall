module ContentBlockManager::ContentBlock::EditionHelper
  def published_date(content_block_edition)
    tag.time(
      content_block_edition.updated_at.to_fs(:long_ordinal_with_at),
      class: "date",
      datetime: content_block_edition.updated_at.iso8601,
      lang: "en",
    )
  end

  def scheduled_date(content_block_edition)
    tag.time(
      content_block_edition.scheduled_publication.to_fs(:long_ordinal_with_at),
      class: "date",
      datetime: content_block_edition.scheduled_publication.iso8601,
      lang: "en",
    )
  end

  def formatted_instructions_to_publishers(content_block_edition)
    if content_block_edition.instructions_to_publishers.present?
      simple_format(
        auto_link(content_block_edition.instructions_to_publishers, html: { class: "govuk-link", target: "_blank", rel: "noopener" }),
        { class: "govuk-!-margin-top-0" },
        { sanitize_options: { attributes: %w[href class target rel] } },
      )
    else
      "None"
    end
  end
end
