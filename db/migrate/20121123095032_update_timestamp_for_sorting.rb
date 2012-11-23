class UpdateTimestampForSorting < ActiveRecord::Migration
  def up
    execute %{
      UPDATE editions
      SET timestamp_for_sorting = delivered_on
      WHERE type = 'Speech'
    }

    execute %{
      UPDATE editions
      SET timestamp_for_sorting = publication_date
      WHERE type = 'Publication'
    }

    execute %{
      UPDATE editions
      SET timestamp_for_sorting = first_published_at
      WHERE type NOT IN ('Speech', 'Publication')
      AND (published_major_version IS NULL
      OR published_major_version = 1)
    }

    execute %{
      UPDATE editions
      SET timestamp_for_sorting = published_at
      WHERE type NOT IN ('Speech', 'Publication')
      AND (published_major_version > 1)
    }
  end
end
