class RemoveVersionsWithoutAWhodunnit < ActiveRecord::Migration
  def change
    Version.where(whodunnit: nil).delete_all
  end
end
