module Organisation::OrganisationTypeConcern
  extend ActiveSupport::Concern

  included do
    validates :organisation_type_key,
              inclusion: { in: OrganisationType.valid_keys }
    validates :parent_organisations,
              length: { minimum: 1, message: "must not be empty for sub-organisations" },
              if: lambda { organisation_type_key == :sub_organisation }
    validates :govuk_status,
              inclusion: {in: ['exempt'], message: "must be 'exempt' for devolved administrations"},
              if: lambda { organisation_type_key == :devolved_administration }

    # Creates a scope for each department type. (eg. Organisation.ministerial_departments)
    OrganisationType.valid_keys.each do |type_key|
      scope type_key.to_s.pluralize, where(organisation_type_key: type_key)
    end

    scope :excluding_ministerial_departments, lambda {
      where("organisation_type_key != 'ministerial_department'")
    }

    scope :listable, lambda {
      excluding_govuk_status_closed.with_translations.where("organisation_type_key != 'sub_organisation'")
    }
  end

  def organisation_type_key
    read_attribute(:organisation_type_key).nil? ? nil : read_attribute(:organisation_type_key).to_sym
  end

  def organisation_type
    organisation_type_key.present? ? OrganisationType.get(organisation_type_key) : nil
  end
  alias_method :type, :organisation_type

  def organisation_type=(organisation_type)
    self.organisation_type_key = organisation_type.key
  end
  alias_method :type=, :organisation_type=

  def active_child_organisations_excluding_sub_organisations
    @active_child_organisations_excluding_sub_organisations ||=
      child_organisations.excluding_govuk_status_closed.with_translations.where("organisation_type_key != 'sub_organisation'")
  end

  def active_child_organisations_excluding_sub_organisations_grouped_by_type
    @active_child_organisations_excluding_sub_organisations_grouped_by_type ||=
      active_child_organisations_excluding_sub_organisations.group_by(&:organisation_type).sort_by { |type, department| type.listing_position }
  end
end
