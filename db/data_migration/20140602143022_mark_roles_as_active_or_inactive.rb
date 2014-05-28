Role.all.select(&:occupied?).update_all(status: "active")
Role.all.reject(&:occupied?).update_all(status: "inactive", reason_for_inactivity: "no_longer_exists")
