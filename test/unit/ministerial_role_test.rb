require 'test_helper'

class MinisterialRoleTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    ministerial_role = build(:ministerial_role)
    assert ministerial_role.valid?
  end

  test "should set a slug from the ministerial role name" do
    role = create(:ministerial_role, name: 'Prime Minister, Cabinet Office')
    assert_equal 'prime-minister-cabinet-office', role.slug
  end

  test "should not change the slug when the name is changed" do
    role = create(:ministerial_role, name: 'Prime Minister, Cabinet Office')
    role.update_attributes(name: 'Prime Minister')
    assert_equal 'prime-minister-cabinet-office', role.slug
  end

  test "should generate user-friendly types" do
    assert_equal "Ministerial", build(:ministerial_role).humanized_type
    assert_equal "Ministerial", MinisterialRole.humanized_type
  end

  test "should not be destroyable when it is responsible for documents" do
    ministerial_role = create(:ministerial_role, documents: [create(:document)])
    refute ministerial_role.destroyable?
    assert_equal false, ministerial_role.destroy
  end

  test "should be destroyable when it has no appointments, organisations or documents" do
    ministerial_role = create(:ministerial_role, role_appointments: [], organisations: [], documents: [])
    assert ministerial_role.destroyable?
    assert ministerial_role.destroy
  end

  test "can never be a permanent secretary" do
    ministerial_role = build(:ministerial_role, permanent_secretary: true)
    refute ministerial_role.permanent_secretary?
    refute ministerial_role.permanent_secretary
  end

  test "should return cabinet roles in correct order" do
    nick_clegg = create(:person, forename: 'Nick', surname: 'Clegg')
    jeremy_hunt = create(:person, forename: 'Jeremy', surname: 'Hunt')
    edward_garnier = create(:person, forename: 'Edward', surname: 'Garnier')
    david_cameron = create(:person, forename: 'David', surname: 'Cameron')
    philip_hammond = create(:person, forename: 'Philip', surname: 'Hammond')

    deputy_prime_minister = create(:ministerial_role, name: 'Deputy Prime Minister', cabinet_member: true)
    culture_minister = create(:ministerial_role, name: 'Secretary of State for Culture', cabinet_member: true)
    solicitor_general = create(:ministerial_role, name: 'Solicitor General', cabinet_member: false)
    prime_minister = create(:ministerial_role, name: 'Prime Minister', cabinet_member: true)
    defence_minister = create(:ministerial_role, name: 'Secretary of State for Defence', cabinet_member: true)

    create(:ministerial_role_appointment, role: deputy_prime_minister, person: nick_clegg)
    create(:ministerial_role_appointment, role: culture_minister, person: jeremy_hunt)
    create(:ministerial_role_appointment, role: solicitor_general, person: edward_garnier)
    create(:ministerial_role_appointment, role: prime_minister, person: david_cameron)
    create(:ministerial_role_appointment, role: defence_minister, person: philip_hammond)

    assert_equal [prime_minister, deputy_prime_minister, defence_minister, culture_minister], MinisterialRole.cabinet
  end
end