class AddCabinetMemberToRoles < ActiveRecord::Migration
  class Role < ActiveRecord::Base
  end
  class MinisterialRole < Role
  end

  def change
    add_column :roles, :cabinet_member, :boolean, after: :permanent_secretary, default: false, null: false

    MinisterialRole.reset_column_information

    MinisterialRole.record_timestamps = false
    MinisterialRole.all.each do |role|
      role.update_attributes! cabinet_member: (role.name =~ /^((First|Chief) )?Secretary|(Deputy )?Prime|.*Chancellor/).present?
    end
    MinisterialRole.record_timestamps = true
  end
end
