require 'unit/whitehall/authority/authority_test_helper'
require 'ostruct'

class GDSAdminTest < ActiveSupport::TestCase
  def gds_admin(id = 1)
    OpenStruct.new(id: id, gds_admin?: true, organisation: build(:organisation))
  end

  def non_gds_admin(id = 2)
    OpenStruct.new(id: id, gds_admin?: false, organisation: build(:organisation))
  end

  include AuthorityTestHelper

  test 'non gds admin cannot create a new organisation' do
    refute enforcer_for(non_gds_admin, Organisation).can?(:create)
  end

  test 'gds admin can create a new organisation' do
    assert enforcer_for(gds_admin, Organisation).can?(:create)
  end

  test 'can export editions' do
    assert enforcer_for(gds_admin, Edition).can?(:export)
  end

  test 'can manage governments' do
    _government = Government.new
    assert enforcer_for(gds_admin, Government).can?(:manage)

    refute enforcer_for(non_gds_admin, Government).can?(:manage)
  end

  test 'can mark editions as political' do
    assert enforcer_for(gds_admin, normal_edition).can?(:mark_political)
  end

  test 'can modify historic editions' do
    assert enforcer_for(gds_admin, historic_edition).can?(:modify)
  end
end
