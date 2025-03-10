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
end
