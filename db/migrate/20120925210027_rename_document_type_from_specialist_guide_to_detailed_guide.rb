class RenameDocumentTypeFromSpecialistGuideToDetailedGuide < ActiveRecord::Migration
  def up
    update("UPDATE documents SET document_type = 'DetailedGuide' WHERE document_type = 'SpecialistGuide'")
  end

  def down
    update("UPDATE documents SET document_type = 'SpecialistGuide' WHERE document_type = 'DetailedGuide'")
  end
end
