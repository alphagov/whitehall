require 'test_helper'

class OrganisationsIndexPresenterTest < ActiveSupport::TestCase
  def organisation_variety_pack
    {
      executive_office:            build(:organisation, organisation_type_key: :executive_office),
      ministerial_department:      build(:organisation, organisation_type_key: :ministerial_department),
      non_ministerial_department:  build(:organisation, organisation_type_key: :non_ministerial_department),
      executive_agency:            build(:organisation, organisation_type_key: :executive_agency),
      executive_ndpb:              build(:organisation, organisation_type_key: :executive_ndpb),
      advisory_ndpb:               build(:organisation, organisation_type_key: :advisory_ndpb),
      tribunal_ndpb:               build(:organisation, organisation_type_key: :tribunal_ndpb),
      public_corporation:          build(:organisation, organisation_type_key: :public_corporation),
      independent_monitoring_body: build(:organisation, organisation_type_key: :independent_monitoring_body),
      adhoc_advisory_group:        build(:organisation, organisation_type_key: :adhoc_advisory_group),
      devolved_administration:     build(:organisation, organisation_type_key: :devolved_administration),
      other:                       build(:organisation, organisation_type_key: :other)
    }
  end

  test "#executive_offices should return the PM's office before the deputy's office" do
    dep_office = build(:organisation, slug: "prime-ministers-office-10-downing-street", organisation_type_key: :executive_office)
    pm_office = build(:organisation, slug: "deputy-prime-ministers-office", organisation_type_key: :executive_office)
    other_office = build(:organisation, organisation_type_key: :executive_agency)
    subject = OrganisationsIndexPresenter.new([dep_office, pm_office, other_office])

    assert_equal [pm_office, dep_office], subject.executive_offices
  end

  test "#ministerial_departments should return all ministerial_departments presented" do
    orgs = organisation_variety_pack
    subject = OrganisationsIndexPresenter.new(orgs.values)
    assert_equal [orgs[:ministerial_department]], subject.ministerial_departments
    assert subject.ministerial_departments.is_a? OrganisationsIndexPresenter
  end

  test "#non_ministerial_departments should return all non_ministerial_departments presented" do
    orgs = organisation_variety_pack
    subject = OrganisationsIndexPresenter.new(orgs.values)
    assert_equal [orgs[:non_ministerial_department]], subject.non_ministerial_departments
    assert subject.non_ministerial_departments.is_a? OrganisationsIndexPresenter
  end

  test "#public_corporations should return all public_corporations presented" do
    orgs = organisation_variety_pack
    subject = OrganisationsIndexPresenter.new(orgs.values)
    assert_equal [orgs[:public_corporation]], subject.public_corporations
    assert subject.public_corporations.is_a? OrganisationsIndexPresenter
  end

  test "#devolved_administrations should return all devolved_administrations presented" do
    orgs = organisation_variety_pack
    subject = OrganisationsIndexPresenter.new(orgs.values)
    assert_equal [orgs[:devolved_administration]], subject.devolved_administrations
    assert subject.devolved_administrations.is_a? OrganisationsIndexPresenter
  end

  test "#agencies_and_government_bodies should return all organisations whose type is an agency_or_public_body presented" do
    aagb_org = build(:organisation, organisation_type: OrganisationType.executive_agency)
    non_aagb_org = build(:organisation, organisation_type: OrganisationType.executive_office)

    subject = OrganisationsIndexPresenter.new([aagb_org, non_aagb_org])

    assert subject.agencies_and_government_bodies.include?(aagb_org)
    refute subject.agencies_and_government_bodies.include?(non_aagb_org)

    assert subject.agencies_and_government_bodies.is_a? OrganisationsIndexPresenter
  end


  def status_variety_pack
    [ build(:organisation, govuk_status: 'live'),
      build(:organisation, govuk_status: 'live'),
      build(:organisation, govuk_status: 'exempt'),
      build(:organisation, govuk_status: 'transitioning') ]
  end

  test "#live_count should return the number of live ones" do
    assert_equal 2, OrganisationsIndexPresenter.new(status_variety_pack).live_count
  end

  test "#exempt_count should return the number of exempt ones" do
    assert_equal 1, OrganisationsIndexPresenter.new(status_variety_pack).exempt_count
  end

  test "#potentially_live_count should return the number of exempt ones" do
    assert_equal 3, OrganisationsIndexPresenter.new(status_variety_pack).potentially_live_count
  end
end
