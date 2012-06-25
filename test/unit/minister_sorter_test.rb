unless defined? Rails
  lib = File.expand_path("../../../app/models", __FILE__)
  $:.unshift lib unless $:.include?(lib)
  require "minister_sorter"
  require "minitest/autorun"
end

class MinisterSorterTest < MiniTest::Unit::TestCase
  class MockRole < Struct.new(:name, :seniority, :cabinet_member, :current_people)
    def cabinet_member?
      self.cabinet_member
    end

    def inspect(*args)
      "<role #{name}, seniority=#{seniority}, #{cabinet_member? ? "cabinet" : "other"}>"
    end
  end

  class MockPerson < Struct.new(:sort_key)
    def inspect(*args)
      "<person #{sort_key}>"
    end
  end

  def role(*args)
    MockRole.new(*args)
  end

  def person(*args)
    MockPerson.new(*args)
  end

  def test_should_list_cabinet_ministers_by_person_sort_key
    roles = [
      r0 = role("r0", 0, true,  [d = person("d")]),
      r1 = role("r1", 0, false, [c = person("c")]),
      r2 = role("r2", 0, true,  [a = person("a"), b = person("b")]),
    ]

    expected = [
      [a, [r2]],
      [b, [r2]],
      [d, [r0]],
    ]

    set = MinisterSorter.new(roles)
    assert_equal expected, set.cabinet_ministers
  end

  def test_should_list_all_cabinet_ministers_roles_including_non_cabinet_roles_in_seniority_order
    roles = [
      r0 = role("r0", 2, false, [a = person("a")]),
      r1 = role("r1", 1, true,  [a]),
      r2 = role("r2", 3, false, [a]),
    ]

    expected = [
      [a, [r1, r0, r2]],
    ]

    set = MinisterSorter.new(roles)
    assert_equal expected, set.cabinet_ministers
  end

  def test_should_list_ministers_with_no_cabinet_roles_by_person_sort_key
    roles = [
      r0 = role("r0", 0, false, [c = person("c"), b = person("b")]),
      r1 = role("r1", 0, true,  [c]),
      r2 = role("r2", 0, false, [a = person("a")]),
    ]

    expected = [
      [a, [r2]],
      [b, [r0]],
    ]

    set = MinisterSorter.new(roles)
    assert_equal expected, set.other_ministers
  end
end
