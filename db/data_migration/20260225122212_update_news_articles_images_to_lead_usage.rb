# This data migration updates the usage of images that are currently used as govspeak embeds in news articles, to be lead images instead, if the image_data_id of the image has been stored in the block_content's image field.
# The image data reference is then removed from the block content of the edition translation, as it is no longer needed.
#
# The queries check:
# - that the image_data of the image matches the image reference in the block content of the edition translation
# - that the image matches an image record under the edition
# - that the configurable document type is one of news_story, world_news_story, government_response, press_release, as these are the only config-driven document types that should have lead images
# - the state of the edition - all states except deleted and superseded
# - the english locale; while we do have multiple translations for news articles, we are removing the possibility to have different lead images on different translations of the same edition (this was only supported in the blocks), so we can just take the english translation to get the lead image
# - that the usage is govspeak_embed, as we should not be updating any other usages
# - that the image data reference is present and not (json) null nor empty string
# - that the image data reference is either an integer or a string, as we have cases of stringified integers

editions_images_and_translations_count_query = <<~SQL
  SELECT
    e.id AS edition_id,
    i.id AS image_id,
    et.id AS translation_id
  FROM images i
  JOIN edition_translations et
    ON i.image_data_id = CAST(JSON_EXTRACT(et.block_content, '$.image') AS UNSIGNED)
  JOIN editions e
    ON et.edition_id = e.id
    AND i.edition_id = e.id
  WHERE e.configurable_document_type IN ('news_story', 'world_news_story', 'government_response', 'press_release')
    AND e.state NOT IN ('superseded', 'deleted')
    AND et.locale = 'en'
    AND i.usage = 'govspeak_embed'
    AND JSON_CONTAINS_PATH(et.block_content, 'one', '$.image')
    AND JSON_UNQUOTE(JSON_EXTRACT(et.block_content, '$.image')) <> 'null'
    AND TRIM(JSON_UNQUOTE(JSON_EXTRACT(et.block_content, '$.image'))) <> ''
    AND JSON_TYPE(JSON_EXTRACT(et.block_content, '$.image')) IN ('INTEGER', 'STRING');
SQL

# The update casts the ID of the image data as it might be stored as a string.
update_query = <<~SQL
  UPDATE images i
  JOIN edition_translations et
    ON i.image_data_id = CAST(JSON_EXTRACT(et.block_content, '$.image') AS UNSIGNED)
  JOIN editions e
    ON et.edition_id = e.id
    AND i.edition_id = e.id
  SET
    i.usage = 'lead',
    et.block_content = JSON_REMOVE(et.block_content, '$.image')
  WHERE e.configurable_document_type IN ('news_story', 'world_news_story', 'government_response', 'press_release')
    AND e.state NOT IN ('superseded', 'deleted')
    AND et.locale = 'en'
    AND i.usage = 'govspeak_embed'
    AND JSON_CONTAINS_PATH(et.block_content, 'one', '$.image')
    AND JSON_UNQUOTE(JSON_EXTRACT(et.block_content, '$.image')) <> 'null'
    AND TRIM(JSON_UNQUOTE(JSON_EXTRACT(et.block_content, '$.image'))) <> ''
    AND JSON_TYPE(JSON_EXTRACT(et.block_content, '$.image')) IN ('INTEGER', 'STRING');
SQL

ActiveRecord::Base.transaction do
  updated_editions_and_images = ActiveRecord::Base.connection.select_all(editions_images_and_translations_count_query).to_a
  updated_image_ids = updated_editions_and_images.map { |row| row["image_id"] }
  updated_edition_ids = updated_editions_and_images.map { |row| row["edition_id"] }
  updated_translations_ids = updated_editions_and_images.map { |row| row["translation_id"] }
  puts "Updating edition and images:\n#{updated_editions_and_images.map { |row| "Edition ID: #{row['edition_id']}, Image ID: #{row['image_id']}" }.join("\n")}"
  puts "Total editions to be updated: #{updated_edition_ids.size}, total unique editions: #{updated_edition_ids.uniq.size}"
  puts "Total images to be updated: #{updated_image_ids.size}, total unique images: #{updated_image_ids.uniq.size}"
  puts "Total translations to be updated: #{updated_translations_ids.size}, total unique translations: #{updated_translations_ids.uniq.size}"
  puts "----------------------------------------------"
  affected_rows = ActiveRecord::Base.connection.update(update_query)
  puts "Updated a total of #{affected_rows} rows in the database." # This will output the sum of images and editions translations rows updated.
end
