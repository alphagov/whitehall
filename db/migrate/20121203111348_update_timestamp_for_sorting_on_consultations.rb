class UpdateTimestampForSortingOnConsultations < ActiveRecord::Migration
  def up
    execute %{
      UPDATE editions
      SET timestamp_for_sorting=opening_on
      WHERE type='Consultation' and published_major_version='1'
    }
  end

  def down
    # No down as this there are no schema changes
  end
end
