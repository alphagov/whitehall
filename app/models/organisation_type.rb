class OrganisationType
  DATA = {
    executive_office:            { name: "Executive office",                       analytics_prefix: "EO", agency_or_public_body: false, non_departmental_public_body: false, allowed_promotional: true },
    ministerial_department:      { name: "Ministerial department",                 analytics_prefix: "D" , agency_or_public_body: false, non_departmental_public_body: false, allowed_promotional: false },
    non_ministerial_department:  { name: "Non-ministerial department",             analytics_prefix: "D" , agency_or_public_body: false, non_departmental_public_body: false, allowed_promotional: false },
    executive_agency:            { name: "Executive agency",                       analytics_prefix: "EA", agency_or_public_body: true,  non_departmental_public_body: false, allowed_promotional: false },
    executive_ndpb:              { name: "Executive non-departmental public body", analytics_prefix: "PB", agency_or_public_body: true,  non_departmental_public_body: true , allowed_promotional: false },
    advisory_ndpb:               { name: "Advisory non-departmental public body",  analytics_prefix: "PB", agency_or_public_body: true,  non_departmental_public_body: true , allowed_promotional: false },
    tribunal_ndpb:               { name: "Tribunal non-departmental public body",  analytics_prefix: "PB", agency_or_public_body: true,  non_departmental_public_body: true , allowed_promotional: false },
    public_corporation:          { name: "Public corporation",                     analytics_prefix: "PC", agency_or_public_body: false, non_departmental_public_body: false, allowed_promotional: false },
    independent_monitoring_body: { name: "Independent monitoring body",            analytics_prefix: "IM", agency_or_public_body: true,  non_departmental_public_body: false, allowed_promotional: false },
    adhoc_advisory_group:        { name: "Ad-hoc advisory group",                  analytics_prefix: "AG", agency_or_public_body: true,  non_departmental_public_body: false, allowed_promotional: false },
    devolved_administration:     { name: "Devolved administration",                analytics_prefix: "DA", agency_or_public_body: false, non_departmental_public_body: false, allowed_promotional: false },
    sub_organisation:            { name: "Sub-organisation",                       analytics_prefix: "OT", agency_or_public_body: false, non_departmental_public_body: false, allowed_promotional: false },
    other:                       { name: "Other",                                  analytics_prefix: "OT", agency_or_public_body: true,  non_departmental_public_body: false, allowed_promotional: false },
    civil_service:               { name: "Civil Service",                          analytics_prefix: "CS", agency_or_public_body: false, non_departmental_public_body: false, allowed_promotional: true },
  }

  LISTING_ORDER = [
    :executive_office,
    :ministerial_department,
    :non_ministerial_department,
    :executive_agency,
    :executive_ndpb,
    :advisory_ndpb,
    :tribunal_ndpb,
    :public_corporation,
    :independent_monitoring_body,
    :adhoc_advisory_group,
    :devolved_administration,
    :sub_organisation,
    :other,
    :civil_service,
  ]


  @@instances = {}

  def self.get(key)
    key = key.to_sym
    raise KeyError, "#{key} is not a known organisation type." if DATA[key].nil?

    @@instances[key] ||= new(key, DATA[key])
  end

  def self.all
    DATA.keys.map {|key| get(key)}
  end

  def self.in_listing_order
    LISTING_ORDER.map {|key| get(key)}
  end

  def self.valid_keys
    DATA.keys
  end


  def self.allowed_promotional_keys
    DATA.select {|key, value| value[:allowed_promotional] }.keys
  end

  def self.executive_office
    get :executive_office
  end
  def self.ministerial_department
    get :ministerial_department
  end
  def self.non_ministerial_department
    get :non_ministerial_department
  end
  def self.executive_agency
    get :executive_agency
  end
  def self.executive_ndpb
    get :executive_ndpb
  end
  def self.advisory_ndpb
    get :advisory_ndpb
  end
  def self.tribunal_ndpb
    get :tribunal_ndpb
  end
  def self.public_corporation
    get :public_corporation
  end
  def self.independent_monitoring_body
    get :independent_monitoring_body
  end
  def self.adhoc_advisory_group
    get :adhoc_advisory_group
  end
  def self.devolved_administration
    get :devolved_administration
  end
  def self.sub_organisation
    get :sub_organisation
  end
  def self.other
    get :other
  end
  def self.civil_service
    get :civil_service
  end


  attr_reader :key, :name, :analytics_prefix, :agency_or_public_body, :non_departmental_public_body
  alias_method :agency_or_public_body?,        :agency_or_public_body
  alias_method :non_departmental_public_body?, :non_departmental_public_body

  def initialize(key, data)
    @key                          = key
    @name                         = data[:name]
    @analytics_prefix             = data[:analytics_prefix]
    @agency_or_public_body        = data[:agency_or_public_body]
    @non_departmental_public_body = data[:non_departmental_public_body]
  end

  def listing_position
    LISTING_ORDER.index(key)
  end

  def allowed_promotional?
    DATA[key][:allowed_promotional]
  end
  def executive_office?
    key == :executive_office
  end
  def ministerial_department?
    key == :ministerial_department
  end
  def non_ministerial_department?
    key == :non_ministerial_department
  end
  def executive_agency?
    key == :executive_agency
  end
  def executive_ndpb?
    key == :executive_ndpb
  end
  def advisory_ndpb?
    key == :advisory_ndpb
  end
  def tribunal_ndpb?
    key == :tribunal_ndpb
  end
  def public_corporation?
    key == :public_corporation
  end
  def independent_monitoring_body?
    key == :independent_monitoring_body
  end
  def adhoc_advisory_group?
    key == :adhoc_advisory_group
  end
  def devolved_administration?
    key == :devolved_administration
  end
  def sub_organisation?
    key == :sub_organisation
  end
  def other?
    key == :other
  end
  def civil_service?
    key == :civil_service
  end
end
