class UpdateTimestampForSortingOnSpeeches < ActiveRecord::Migration
  def up
    update %{
      UPDATE editions
        SET timestamp_for_sorting = delivered_on
          WHERE type = 'Speech'
    }
  end

  def down
    update %{
      UPDATE editions
        SET timestamp_for_sorting = first_published_at
          WHERE type = 'Speech'
    }
  end
end
