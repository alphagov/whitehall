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
      scope type_key.to_s.pluralize, -> { where(organisation_type_key: type_key) }
    end

    scope :excluding_ministerial_departments, -> {
      where("organisation_type_key != 'ministerial_department'")
    }

    scope :listable, -> {
      excluding_govuk_status_closed.with_translations(I18n.locale)
    }

    scope :allowed_promotional, -> {
      where(organisation_type_key: OrganisationType.allowed_promotional_keys)
    }

    scope :hmcts_tribunals, -> {
      hmcts_id = Organisation.where(slug: "hm-courts-and-tribunals-service").ids.first
      joins(:parent_organisational_relationships).
        where(organisation_type_key: :tribunal_ndpb).
        where("organisational_relationships.parent_organisation_id" => hmcts_id)
    }

    scope :excluding_hmcts_tribunals, -> {
      hmcts_id = Organisation.where(slug: "hm-courts-and-tribunals-service").ids.first
      joins("LEFT JOIN organisational_relationships parent_organisational_relationships
        ON parent_organisational_relationships.child_organisation_id = organisations.id").
      where("NOT (parent_organisational_relationships.parent_organisation_id = ? AND
              organisations.organisation_type_key = ?) OR
              parent_organisational_relationships.child_organisation_id IS NULL",
              hmcts_id, :tribunal_ndpb)
    }

    scope :excluding_courts, -> { where.not(organisation_type_key: :court) }

    scope :excluding_courts_and_tribunals, -> { excluding_courts.excluding_hmcts_tribunals }
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
      child_organisations.excluding_govuk_status_closed.with_translations(I18n.locale).where("organisation_type_key != 'sub_organisation'").ordered_by_name_ignoring_prefix
  end

  def active_child_organisations_excluding_sub_organisations_grouped_by_type
    @active_child_organisations_excluding_sub_organisations_grouped_by_type ||=
      active_child_organisations_excluding_sub_organisations.group_by(&:organisation_type).sort_by { |type, department| type.listing_position }
  end

  def can_index_in_search?
    super && !organisation_type.court?
  end

  def can_publish_to_publishing_api?
    super && !organisation_type.court?
  end

  def hmcts_tribunal?
    organisation_type_key == :tribunal_ndpb &&
      parent_organisations.pluck(:slug).include?("hm-courts-and-tribunals-service")
  end

  def court_or_hmcts_tribunal?
    organisation_type.court? || hmcts_tribunal?
  end
end
