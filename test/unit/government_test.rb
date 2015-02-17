require 'test_helper'

class GovernmentTest < ActiveSupport::TestCase
  test "automatically adds a slug on creation" do
    government = FactoryGirl.create(:government, name: "2005 to 2010 Labour government")

    assert_equal "2005-to-2010-labour-government", government.slug
  end

  test "doesn't change the slug when the name changes" do
    government = FactoryGirl.create(:government, name: "2004 to 2009 Labour government")

    government.name = "2004 to 2009 Labour government"
    government.save!

    assert_equal "2004-to-2009-labour-government", government.slug
  end

  test "doesn't permit blank names" do
    blank_government = FactoryGirl.build(:government, name: '')
    nil_government = FactoryGirl.build(:government, name: nil)

    refute blank_government.valid?
    refute nil_government.valid?
  end

  test "doesn't permit blank start_date" do
    blank_government = FactoryGirl.build(:government, start_date: '')
    nil_government = FactoryGirl.build(:government, start_date: nil)

    refute blank_government.valid?
    refute nil_government.valid?
  end

  test "enforces unique names" do
    FactoryGirl.create(:government, name: "2005 to 2010 Labour government")
    duplicate_government = FactoryGirl.build(:government, name: "2005 to 2010 Labour government")

    refute duplicate_government.valid?
  end

  test "enforces unique slugs" do
    labour_government = FactoryGirl.create(:government, name: "2004 to 2009 Labour government")
    labour_government.name = "2005 to 2010 Labour government"
    labour_government.save!

    labour_government_duplicating_original_name = FactoryGirl.build(:government, name: "2004 to 2009 Labour government")

    refute labour_government_duplicating_original_name.valid?
  end
end
