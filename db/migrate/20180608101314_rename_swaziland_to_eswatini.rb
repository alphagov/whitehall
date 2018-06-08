class RenameSwazilandToEswatini < ActiveRecord::Migration[5.0]
  def change
    WorldLocation
      .where(slug: "swaziland")
      .update_all(slug: "eswatini")
  end
end
