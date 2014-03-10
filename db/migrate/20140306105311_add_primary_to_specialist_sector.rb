class AddPrimaryToSpecialistSector < ActiveRecord::Migration
  def up
    add_column :specialist_sectors, :primary, :boolean, default: false

    SpecialistSector.all.group_by(&:edition).each do |edition, sectors|
      sectors.first.update_attribute(:primary, true) unless edition.nil?
    end
  end

  def down
    remove_column :specialist_sectors, :primary
  end
end
