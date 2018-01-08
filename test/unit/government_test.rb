require 'test_helper'

class GovernmentTest < ActiveSupport::TestCase
  test "automatically adds a slug on creation" do
    government = create(:government, name: "2005 to 2010 Labour government")

    assert_equal "2005-to-2010-labour-government", government.slug
  end

  test "doesn't change the slug when the name changes" do
    government = create(:government, name: "2004 to 2009 Labour government")

    government.name = "2004 to 2009 Labour government"
    government.save!

    assert_equal "2004-to-2009-labour-government", government.slug
  end

  test "doesn't permit blank names" do
    blank_government = build(:government, name: '')
    nil_government = build(:government, name: nil)

    refute blank_government.valid?
    refute nil_government.valid?
  end

  test "doesn't permit blank start_date" do
    blank_government = build(:government, start_date: '')
    nil_government = build(:government, start_date: nil)

    refute blank_government.valid?
    refute nil_government.valid?
  end

  test "enforces unique names" do
    create(:government, name: "2005 to 2010 Labour government")
    duplicate_government = build(:government, name: "2005 to 2010 Labour government")

    refute duplicate_government.valid?
  end

  test "enforces unique slugs" do
    labour_government = create(:government, name: "2004 to 2009 Labour government")
    labour_government.name = "2005 to 2010 Labour government"
    labour_government.save!

    labour_government_duplicating_original_name = build(:government, name: "2004 to 2009 Labour government")

    refute labour_government_duplicating_original_name.valid?
  end

  test "prevents overlapping governments" do
    existing_government = create(:government,
      start_date: "2011-01-01",
      end_date: "2012-01-01")

    government_overlapping_start = build(:government,
      start_date: "2010-06-01",
      end_date: "2011-06-01")
    government_overlapping_end = build(:government,
      start_date: "2011-06-01",
      end_date: "2012-06-01")

    government_before = build(:government,
      start_date: "2009-06-01",
      end_date: "2010-06-01")
    government_after = build(:government,
      start_date: "2012-06-01",
      end_date: "2013-06-01")

    government_starting_immediately = build(:government,
      start_date: existing_government.end_date,)

    refute government_overlapping_start.valid?
    refute government_overlapping_end.valid?

    assert government_before.valid?
    assert government_after.valid?

    assert government_starting_immediately.valid?
  end

  test "prevents new open governments when one is already open" do
    current_open_government = create(:government,
      start_date: "2011-01-01",
      end_date: nil)

    historic_government = build(:government,
      start_date: "2008-01-01",
      end_date: "2010-01-01")

    new_open_government = build(:government,
      start_date: "2015-01-01",
      end_date: nil)

    assert historic_government.valid?

    refute new_open_government.valid?
    current_open_government.update_attribute(:end_date, "2014-01-01")
    assert new_open_government.valid?
  end
end

class GovernmentOnDateTest < ActiveSupport::TestCase
  setup do
    @current_government = create(:current_government)
    @previous_government = create(:previous_government)
    @even_earlier_government = create(:government,
                                start_date: @previous_government.start_date - 4.years,
                                end_date: @previous_government.start_date - 1.day)
  end

  test "knows the correct current government" do
    assert_equal @current_government, Government.current
  end

  test "knows the active government at a date" do
    assert_equal @current_government, Government.on_date(Date.today)
    assert_equal @previous_government, Government.on_date(4.years.ago)
    assert_equal @previous_government, Government.on_date(@previous_government.end_date - 1.day)
    assert_equal @current_government, Government.on_date(@current_government.start_date)
  end

  test "#on_date returns nil for date when no government exist" do
    assert_nil Government.on_date(@even_earlier_government.start_date - 1.day)
  end

  test "#on_date returns nil for future dates" do
    assert_nil Government.on_date(Date.tomorrow), "tomorrow"
  end

  test '#current? is true for the current government' do
    assert @current_government.current?
  end

  test '#current? is false for previous governments' do
    refute @previous_government.current?
  end
end
