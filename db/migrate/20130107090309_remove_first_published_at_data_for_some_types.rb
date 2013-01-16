class RemoveFirstPublishedAtDataForSomeTypes < ActiveRecord::Migration
  def up
    execute %{ UPDATE editions SET first_published_at = NULL WHERE type IN ('Consultation', 'Speech', 'Publication'); }
  end

  def down
    # Only data changed so no down.
  end
end
