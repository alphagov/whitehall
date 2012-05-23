require 'test_helper'

class MinisterialRoleTest < ActiveSupport::TestCase
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
    ministerial_role = create(:ministerial_role, editions: [create(:edition)])
    refute ministerial_role.destroyable?
    assert_equal false, ministerial_role.destroy
  end

  test "should be destroyable when it has no appointments, organisations or documents" do
    ministerial_role = create(:ministerial_role, role_appointments: [], organisations: [], editions: [])
    assert ministerial_role.destroyable?
    assert ministerial_role.destroy
  end

  test "can never be a permanent secretary" do
    ministerial_role = build(:ministerial_role, permanent_secretary: true)
    refute ministerial_role.permanent_secretary?
    refute ministerial_role.permanent_secretary
  end

  test 'should return search index data suitable for Rummageable' do
    person = create(:person, forename: 'David', surname: 'Cameron', biography: 'David Cameron became Prime Minister in May 2010.')
    ministerial_role = create(:ministerial_role, name: 'Prime Minister')
    create(:ministerial_role_appointment, role: ministerial_role, person: person)

    assert_equal 'David Cameron (Prime Minister)', ministerial_role.search_index['title']
    assert_equal "/government/ministers/#{ministerial_role.slug}", ministerial_role.search_index['link']
    assert_equal 'David Cameron became Prime Minister in May 2010.', ministerial_role.search_index['indexable_content']
    assert_equal 'minister', ministerial_role.search_index['format']
  end

  test 'should add ministerial role to search index on creating' do
    ministerial_role = build(:ministerial_role)

    search_index_data = stub('search index data')
    ministerial_role.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data)

    ministerial_role.save
  end

  test 'should add ministerial role to search index on updating' do
    ministerial_role = create(:ministerial_role)

    search_index_data = stub('search index data')
    ministerial_role.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data)

    ministerial_role.name = 'Ministry of Junk'
    ministerial_role.save
  end

  test 'should remove ministerial role from search index on destroying' do
    ministerial_role = create(:ministerial_role)
    Rummageable.expects(:delete).with("/government/ministers/#{ministerial_role.slug}")
    ministerial_role.destroy
  end

  test 'should return search index data for all ministerial roles' do
    nick_clegg = create(:person, forename: 'Nick', surname: 'Clegg', biography: 'Cleggy.')
    jeremy_hunt = create(:person, forename: 'Jeremy', surname: 'Hunt', biography: 'Hunty.')
    edward_garnier = create(:person, forename: 'Edward', surname: 'Garnier', biography: 'Garnerian.')
    david_cameron = create(:person, forename: 'David', surname: 'Cameron', biography: 'Cameronian.')

    deputy_prime_minister = create(:ministerial_role, name: 'Deputy Prime Minister', cabinet_member: true)
    culture_minister = create(:ministerial_role, name: 'Secretary of State for Culture', cabinet_member: true)
    solicitor_general = create(:ministerial_role, name: 'Solicitor General', cabinet_member: false)
    prime_minister = create(:ministerial_role, name: 'Prime Minister', cabinet_member: true)

    create(:ministerial_role_appointment, role: deputy_prime_minister, person: nick_clegg)
    create(:ministerial_role_appointment, role: culture_minister, person: jeremy_hunt)
    create(:ministerial_role_appointment, role: solicitor_general, person: edward_garnier)
    create(:ministerial_role_appointment, role: prime_minister, person: david_cameron)

    results = MinisterialRole.search_index

    assert_equal 4, results.length
    assert_equal({ 'title' => 'Nick Clegg (Deputy Prime Minister)', 'link' => '/government/ministers/deputy-prime-minister', 'indexable_content' => 'Cleggy.', 'format' => 'minister' }, results[0])
    assert_equal({ 'title' => 'Jeremy Hunt (Secretary of State for Culture)', 'link' => '/government/ministers/secretary-of-state-for-culture', 'indexable_content' => 'Hunty.', 'format' => 'minister' }, results[1])
    assert_equal({ 'title' => 'Edward Garnier (Solicitor General)', 'link' => '/government/ministers/solicitor-general', 'indexable_content' => 'Garnerian.', 'format' => 'minister' }, results[2])
    assert_equal({ 'title' => 'David Cameron (Prime Minister)', 'link' => '/government/ministers/prime-minister', 'indexable_content' => 'Cameronian.', 'format' => 'minister' }, results[3])
  end
end