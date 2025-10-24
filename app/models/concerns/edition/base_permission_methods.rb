# Sets all default overwritable permission methods for an Edition
module Edition::BasePermissionMethods
  extend ActiveSupport::Concern

  %w[
    can_apply_to_subset_of_nations?
    can_be_associated_with_social_media_accounts?
    can_be_associated_with_topical_events?
    can_be_associated_with_roles?
    can_be_associated_with_role_appointments?
    can_be_fact_checked?
    can_be_grouped_in_collections?
    can_be_tagged_to_worldwide_taxonomy?
    is_associated_with_a_minister?
    organisation_association_enabled?
    worldwide_organisation_association_required?
    world_location_association_required?
  ].each do |method|
    define_method(method) { false }
  end
end
