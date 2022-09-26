module Edition::AuditTrail
  extend ActiveSupport::Concern

  class << self
    attr_accessor :whodunnit
  end

  def self.acting_as(actor)
    original_actor = Edition::AuditTrail.whodunnit
    Edition::AuditTrail.whodunnit = actor
    yield
  ensure
    Edition::AuditTrail.whodunnit = original_actor
  end

  included do
    has_many :versions, -> { order(created_at: :asc, id: :asc) }, as: :item

    has_one :most_recent_version,
            -> { order("versions.created_at DESC, versions.id DESC") },
            class_name: "Version",
            as: :item
    has_one :last_author,
            through: :most_recent_version,
            source: :user

    after_create  :record_create
    before_update :record_update
  end

  def versions_asc
    versions
  end

  def versions_desc
    versions.reverse_order
  end

private

  def record_create
    user = Edition::AuditTrail.whodunnit
    versions.create! event: "create", user: user, state: state
    alert!(user)
  end

  def record_update
    if changed.any?
      user = Edition::AuditTrail.whodunnit
      versions.build event: "update", user: user, state: state
      alert!(user)
    end
  end

  def alert!(user)
    if user && should_alert_for?(user)
      ::MailNotifications.edition_published_by_monitored_user(user).deliver_now
    end
  end

  def should_alert_for?(user)
    ENV["CO_NSS_WATCHKEEPER_EMAIL_ADDRESS"].present? &&
      user.email == ENV["CO_NSS_WATCHKEEPER_EMAIL_ADDRESS"]
  end
end
