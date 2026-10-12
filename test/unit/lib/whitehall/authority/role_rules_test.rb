require_relative "authority_test_helper"
require "ostruct"

class RoleRulesTest < ActiveSupport::TestCase
  def gds_editor(id = 1)
    OpenStruct.new(
      id:,
      gds_editor?: true,
      departmental_editor?: false,
      managing_editor?: false,
      organisation: build(:organisation),
    )
  end

  def managing_editor(id = 1)
    OpenStruct.new(
      id:,
      gds_editor?: false,
      departmental_editor?: false,
      managing_editor?: true,
      organisation: build(:organisation),
    )
  end

  def departmental_editor(id = 1)
    OpenStruct.new(
      id:,
      gds_editor?: false,
      departmental_editor?: true,
      managing_editor?: false,
      organisation: build(:organisation),
    )
  end

  def writer(id = 1)
    OpenStruct.new(
      id:,
      gds_editor?: false,
      departmental_editor?: false,
      managing_editor?: false,
      organisation: build(:organisation),
    )
  end

  include AuthorityTestHelper

  test "GDS editor can reorder cabinet ministers" do
    assert enforcer_for(gds_editor, build(:ministerial_role)).can?(:reorder_cabinet_ministers)
  end

  test "Managing editor cannot reorder cabinet ministers" do
    assert_not enforcer_for(managing_editor, build(:ministerial_role)).can?(:reorder_cabinet_ministers)
  end

  test "Departmental editor cannot reorder cabinet ministers" do
    assert_not enforcer_for(departmental_editor, build(:ministerial_role)).can?(:reorder_cabinet_ministers)
  end

  test "Writer cannot reorder cabinet ministers" do
    assert_not enforcer_for(writer, build(:ministerial_role)).can?(:reorder_cabinet_ministers)
  end

  test "GDS editor can administer ministerial roles" do
    assert enforcer_for(gds_editor, build(:ministerial_role)).can?(:administer)
  end

  test "Managing editor can administer ministerial roles" do
    assert enforcer_for(managing_editor, build(:ministerial_role)).can?(:administer)
  end

  test "Departmental editor can administer ministerial roles" do
    assert enforcer_for(departmental_editor, build(:ministerial_role)).can?(:administer)
  end

  test "Writer can't administer ministerial roles" do
    assert_not enforcer_for(writer, build(:ministerial_role)).can?(:administer)
  end

  test "Writer can administer normal roles" do
    assert enforcer_for(writer, build(:non_ministerial_role_without_organisations)).can?(:administer)
  end
end
