class SyncCheckResult < ApplicationRecord
  # Used to store results of Sync Checks when running migrations. The check_class
  # will be one from the `SyncChecker::Formats` namespace. This is a developer-only
  # model, and will be used to drive a dashboard that measures the progress of
  # migration.

  validates :check_class, presence: true
  validates :item_id, uniqueness: {scope: :check_class}

  serialize :failures

  def self.record(check_class, item_id, failures)
    record = find_or_initialize_by(check_class: check_class.to_s, item_id: item_id)
    record.failures = failures
    record.save!
  end
end
