module Edition::LimitedAccess
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(draft)
      @edition.named_accesses.each do |na|
        draft.named_accesses.create!(email: na.email)
      end
    end
  end

  included do
    enum :access_limited, { disabled: 0, organisations: 1, named_users: 2 }
    has_many :named_accesses, dependent: :destroy, inverse_of: :edition, autosave: true
    after_initialize :set_access_limited
    before_save :destroy_named_accesses_unless_named_users
    before_save :ensure_creator_in_named_accesses, if: :named_users?
    validate :validate_named_users_emails, if: -> { named_users? }
    add_trait Trait
  end

  module ClassMethods
    def access_limited_by_default?
      false
    end
  end

  def access_limited_object
    self
  end

  def access_limited?
    organisations? || named_users?
  end

  delegate :access_limited_by_default?, to: :class

  def access_limited=(value)
    @_access_limited_explicitly_set = true
    super
  end

  def set_access_limited
    return unless new_record?
    return if @_access_limited_explicitly_set

    self.access_limited = access_limited_by_default? ? :organisations : :disabled
    @_access_limited_explicitly_set = false
  end

  def accessible_to?(user)
    user.present? && Whitehall::Authority::Enforcer.new(user, self).can?(:see)
  end

  def access_limited_named_users=(value)
    @access_limited_named_users_input = value
    new_emails = parse_named_user_emails(value).map(&:downcase).uniq

    existing = active_named_accesses.index_by { |na| na.email.downcase }

    existing.each do |email, na|
      na.mark_for_destruction unless new_emails.include?(email)
    end

    new_emails.each do |email|
      named_accesses.build(email:) unless existing.key?(email)
    end
  end

  def access_limited_named_users
    @access_limited_named_users_input || active_named_accesses.map(&:email).join(", ")
  end

private

  def active_named_accesses
    named_accesses.reject(&:marked_for_destruction?)
  end

  def parse_named_user_emails(value)
    (value || "").split(/[\n,]/).map(&:strip).reject(&:blank?)
  end

  def validate_named_users_emails
    if active_named_accesses.empty?
      errors.add(:access_limited_named_users, "must include at least one email address")
    end

    active_named_accesses.select(&:new_record?).each do |na|
      next if URI::MailTo::EMAIL_REGEXP.match?(na.email)

      errors.add(:access_limited_named_users, "#{na.email} is not a valid email address")
    end
  end

  def destroy_named_accesses_unless_named_users
    return if named_users?

    named_accesses.each(&:mark_for_destruction)
  end

  def ensure_creator_in_named_accesses
    return if creator&.email.blank?

    email = creator.email.downcase
    return if active_named_accesses.any? { |na| na.email.casecmp?(email) }

    named_accesses.build(email:)
  end
end
