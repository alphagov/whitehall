# == Schema Information
#
# Table name: roles
#
#  id                           :integer          not null, primary key
#  created_at                   :datetime
#  updated_at                   :datetime
#  type                         :string(255)      default("MinisterialRole"), not null
#  permanent_secretary          :boolean          default(FALSE)
#  cabinet_member               :boolean          default(FALSE), not null
#  slug                         :string(255)
#  chief_of_the_defence_staff   :boolean          default(FALSE), not null
#  whip_organisation_id         :integer
#  seniority                    :integer          default(100)
#  attends_cabinet_type_id      :integer
#  role_payment_type_id         :integer
#  supports_historical_accounts :boolean          default(FALSE), not null
#  whip_ordering                :integer          default(100)
#

class WorldwideOfficeStaffRole < Role
  def worldwide?
    true
  end
end
