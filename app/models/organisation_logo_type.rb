class OrganisationLogoType
  include ActiveRecordLikeInterface

  attr_accessor :id, :title, :class_name

  def self.find(class_name)
    all.detect { |type| type.class_name == class_name } or raise ActiveRecord::RecordNotFound
  end

  NoIdentity = create(
    id: 1, title: "No identity", class_name: "no-identity"
  )
  SingleIdentity = create(
    id: 2, title: "Single Identity", class_name: "single-identity"
  )
  BusinessInnovationSkills = create(
    id: 3, title: "Department for Business, Innovation and Skills", class_name: "bis"
  )
  ScotlandOffice = create(
    id: 4, title: "Scotland Office", class_name: "so"
  )
  HomeOffice = create(
    id: 5, title: "Home Office", class_name: "ho"
  )
  MinistryOfDefence = create(
    id: 6, title: "Ministry of Defence", class_name: "mod"
  )
  WalesOffice = create(
    id: 7, title: "Wales Office", class_name: "wales"
  )
  HMCoastguard = create(
    id: 8, title: "HM Coastguard", class_name: "coastguard"
  )
  Portcullis = create(
    id: 9, title: "Portcullis", class_name: "portcullis"
  )
  UKHydrographicOffice = create(
    id: 10, title: "UK Hydrographic Office", class_name: "ukho"
  )
  ExecutiveOffice = create(
    id: 11, title: "Executive Office", class_name: "eo"
  )
  HMRevenueCustoms = create(
    id: 12, title: "HM Revenue & Customs", class_name: "hmrc"
  )
  UKatomicenergyauthority = create(
    id: 13, title: "UK Atomic Energy Authority", class_name: "ukaea"
  )
end
