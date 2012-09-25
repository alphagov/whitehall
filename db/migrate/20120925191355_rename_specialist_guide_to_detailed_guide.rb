class RenameSpecialistGuideToDetailedGuide < ActiveRecord::Migration
  def up
    update("UPDATE editions SET type = 'DetailedGuide' WHERE type = 'SpecialistGuide'")
  end

  def down
    update("UPDATE editions SET type = 'SpecialistGuide' WHERE type = 'SpecialistGuide'")
  end
end
