module Edition::LimitedAccess
  extend ActiveSupport::Concern

  included do
    attr_accessor :current_user_for_validation

    enum :access_limiting, {
      none: "none",
      organisations: "organisations",
      individuals: "individuals",
    }, prefix: true, default: nil

    has_many :edition_access_limiting_organisations,
             class_name: "AccessLimitingOrganisation",
             dependent: :destroy,
             autosave: true,
             validate: false

    has_many :access_limiting_organisations,
             through: :edition_access_limiting_organisations,
             source: :organisation

    after_initialize :set_access_limited
    after_save :clear_pending_access_limiting_organisation_ids

    validate :access_limiting_organisations_required, if: -> { Flipflop.access_limiting_organisations_ui? && access_limiting_organisations? }
    validate :access_limiting_must_include_current_user_organisation
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
    access_limiting_organisations? || access_limiting_individuals?
  end

  # TODO: Remove once nothing reads or writes `access_limited` (drop-column ticket).
  def access_limiting=(value)
    super
    self.access_limited = !access_limiting_none?
  end

  delegate :access_limited_by_default?, to: :class

  def set_access_limited
    return unless new_record? && access_limiting.nil?

    self.access_limiting = access_limited_by_default? ? :organisations : :none
  end

  def accessible_to?(user)
    user.present? && Whitehall::Authority::Enforcer.new(user, self).can?(:see)
  end

  def access_limiting_organisations_required
    errors.add(:access_limiting_organisation_ids, "must include at least one organisation") if edition_access_limiting_organisations.reject(&:marked_for_destruction?).empty?
  end

  def access_limiting_organisation_ids=(new_ids)
    ids = Array(new_ids).reject(&:blank?).map(&:to_i).uniq
    @pending_access_limiting_organisation_ids = ids

    # Manually update the in-memory association to reflect the submitted IDs.
    # This prevents immediate database writes and ensures the form re-renders correctly.
    edition_access_limiting_organisations.each(&:mark_for_destruction)
    ids.each do |org_id|
      edition_access_limiting_organisations.build(organisation_id: org_id)
    end
  end

  def access_limiting_organisation_ids
    if defined?(@pending_access_limiting_organisation_ids)
      return @pending_access_limiting_organisation_ids.dup
    end

    super
  end

private

  def clear_pending_access_limiting_organisation_ids
    remove_instance_variable(:@pending_access_limiting_organisation_ids) if defined?(@pending_access_limiting_organisation_ids)
  end

  def access_limiting_must_include_current_user_organisation
    return unless current_user_for_validation.present? && access_limited?

    if Flipflop.access_limiting_organisations_ui? && access_limiting_organisations?
      org_ids = edition_access_limiting_organisations
                  .reject(&:marked_for_destruction?)
                  .map(&:organisation_id)

      if org_ids.any? && org_ids.exclude?(current_user_for_validation.organisation&.id)
        errors.add(:access_limiting_organisation_ids, "must include your own organisation")
      end
    elsif organisation_association_enabled? && edition_organisations.map(&:organisation_id).exclude?(current_user_for_validation.organisation&.id)
      errors.add(:base, "Lead or supporting organisations must include your own organisation")
    end
  end
end
