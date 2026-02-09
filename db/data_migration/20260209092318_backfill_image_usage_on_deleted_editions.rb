# Backfill all images of either non-landing-page deleted editions, or editions that have been hard deleted
non_landing_page_count_sql = <<~SQL
  SELECT COUNT(*)
  FROM images
  LEFT JOIN editions ON images.edition_id = editions.id
  WHERE images.usage IS NULL
    AND (
      editions.id IS NULL
      OR (
        editions.state = 'deleted'
        AND editions.type != 'LandingPage'
      )
    );
SQL
non_landing_page_count = ActiveRecord::Base.connection.select_value(non_landing_page_count_sql)
say "About to update #{non_landing_page_count} images on soft or hard deleted non-landing-page editions."

update_non_landing_pages_sql = <<~SQL
  UPDATE images
  LEFT JOIN editions ON images.edition_id = editions.id
  SET images.usage = 'govspeak_embed'
  WHERE images.usage IS NULL
    AND (
      editions.id IS NULL
      OR (
        editions.state = 'deleted'
        AND editions.type != 'LandingPage'
      )
    );
SQL
affected_rows = ActiveRecord::Base.connection.update(update_non_landing_pages_sql)
puts "Updated #{affected_rows} images usage from nil to 'govspeak_embed', on soft or hard deleted non-landing-page editions."

# Backfill landing pages images
landing_pages_image_count_sql = <<~SQL
  SELECT COUNT(*) AS count
  FROM images
  LEFT JOIN editions ON images.edition_id = editions.id
  WHERE images.usage IS NULL
    AND (
      editions.id IS NULL
      OR (
        editions.state = 'deleted'
        AND editions.type = 'LandingPage'
      )
    );
SQL
landing_pages_image_count = ActiveRecord::Base.connection.select_value(landing_pages_image_count_sql)
puts "About to update #{landing_pages_image_count} landing page images."

landing_page_images_select_sql = <<~SQL
  SELECT images.id as image_id
  FROM images
  LEFT JOIN editions ON images.edition_id = editions.id
  WHERE images.usage IS NULL
    AND (
      editions.id IS NULL
      OR (
        editions.state = 'deleted'
        AND editions.type = 'LandingPage'
      )
    );
SQL
landing_pages_images = ActiveRecord::Base.connection.select_values(landing_page_images_select_sql)
landing_pages_images.each do |image_id|
  image = Image.find(image_id)
  image_kind = Whitehall.image_kinds.fetch(image.image_kind)
  image.update!(usage: image_kind.permitted_uses.first)
end
puts "Updated #{landing_pages_images.size} landing page images usage from nil to a landing page permitted use."
