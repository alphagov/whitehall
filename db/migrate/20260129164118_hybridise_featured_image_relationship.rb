class HybridiseFeaturedImageRelationship < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      add_reference :features, :featured_image_data, foreign_key: true, index: true

      execute <<-SQL
        UPDATE features
        INNER JOIN featured_image_data
          ON featured_image_data.featured_imageable_id = features.id
          AND featured_image_data.featured_imageable_type = 'Feature'
        SET features.featured_image_data_id = featured_image_data.id
      SQL

      execute <<-SQL
        UPDATE featured_image_data
        SET featured_imageable_id = NULL, featured_imageable_type = NULL
        WHERE featured_imageable_type = 'Feature'
      SQL
    end
  end

  def down
    safety_assured do
      execute <<-SQL
        UPDATE featured_image_data
        INNER JOIN features ON features.featured_image_data_id = featured_image_data.id
        SET featured_image_data.featured_imageable_id = features.id,
            featured_image_data.featured_imageable_type = 'Feature'
      SQL

      remove_reference :features, :featured_image_data
    end
  end
end
