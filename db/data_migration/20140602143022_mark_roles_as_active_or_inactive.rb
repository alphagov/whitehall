Role.joins(:current_role_appointments).update_all(status: "active")

active_ids = Role.joins(:current_role_appointments).pluck(:id)
Role.where("id NOT in (?)", active_ids).update_all(status: "no_longer_exists")
