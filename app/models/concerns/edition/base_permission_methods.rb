# Sets all default overwritable permission methods for an Edition
module Edition::BasePermissionMethods
  extend ActiveSupport::Concern

  %w[
    can_be_associated_with_social_media_accounts?
    can_be_associated_with_topical_events?
    can_be_associated_with_roles?
    can_be_associated_with_role_appointments?
    can_be_associated_with_worldwide_organisations?
    can_be_fact_checked?
    can_be_related_to_mainstream_content?
    can_be_related_to_organisations?
    can_apply_to_subset_of_nations?
    can_be_grouped_in_collections?
    has_operational_field?
    can_apply_to_local_government?
    national_statistic?
    has_consultation_participation?
    is_associated_with_a_minister?
    statistics?
    can_be_tagged_to_worldwide_taxonomy?
  ].each do |method|
    define_method(method) { false }
  end
end
