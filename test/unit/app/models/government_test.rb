require "test_helper"

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
    blank_government = build(:government, name: "")
    nil_government = build(:government, name: nil)

    assert_not blank_government.valid?
    assert_not nil_government.valid?
  end

  test "doesn't permit blank start_date" do
    blank_government = build(:government, start_date: "")
    nil_government = build(:government, start_date: nil)

    assert_not blank_government.valid?
    assert_not nil_government.valid?
  end

  test "enforces unique names" do
    create(:government, name: "2005 to 2010 Labour government")
    duplicate_government = build(:government, name: "2005 to 2010 Labour government")

    assert_not duplicate_government.valid?
  end

  test "enforces unique slugs" do
    labour_government = create(:government, name: "2004 to 2009 Labour government")
    labour_government.name = "2005 to 2010 Labour government"
    labour_government.save!

    labour_government_duplicating_original_name = build(:government, name: "2004 to 2009 Labour government")

    assert_not labour_government_duplicating_original_name.valid?
  end

  test "#newest_first returns the current government first" do
    previous_government = create(:previous_government)
    current_government = create(:current_government)
    assert Government.first == previous_government
    assert Government.newest_first.first == current_government
  end
end

class GovernmentOnDateTest < ActiveSupport::TestCase
  setup do
    @current_government = create(:current_government)
    @previous_government = create(:previous_government)
    @even_earlier_government = create(
      :government,
      start_date: @previous_government.start_date - 4.years,
      end_date: @previous_government.start_date - 1.day,
    )
  end

  test "knows the correct current government" do
    assert_equal @current_government, Government.current
  end

  test "knows the active government at a date" do
    assert_equal @current_government, Government.on_date(Time.zone.today)
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

  test "#current? is true for the current government" do
    assert @current_government.current?
  end

  test "#current? is false for previous governments" do
    assert_not @previous_government.current?
  end
end
