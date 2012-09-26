class FixBadlyImportedSpecialistGuides < ActiveRecord::Migration
  def repair_broken_headings(govspeak)
    govspeak.gsub(/\.##/, ".\n\n##")
  end

  def update_govspeak(edition)
    edition.update_column(:body, repair_broken_headings(edition.body))
  end

  class SpecialistGuide < Edition; end

  def up
    SpecialistGuide.where("body LIKE ?", "%.##%").each do |guide|
      update_govspeak(guide)
    end
  end

  def down
  end
end
