class AddWhipOrderingToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :whip_ordering, :integer, default: 100
    Role.whip.order(:seniority).each_with_index do |whip, i|
      whip.update_column :whip_ordering, i
    end
  end
end
