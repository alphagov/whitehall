require 'test_helper'

class HomePageListTest < ActiveSupport::TestCase

  test "is invalid without an owner" do
    list = build(:home_page_list, owner: nil)
    refute list.valid?
  end

  test 'is invalid without a name' do
    list = build(:home_page_list, name: '')
    refute list.valid?
  end

  test 'is invalid if the name would breach the database field size' do
    list = build(:home_page_list, name: 'a' * 254) # below max
    assert list.valid?
    list.name += 'a' # 255 - on max
    assert list.valid?
    list.name += 'a' # 256 - above max
    refute list.valid?
  end

  test 'is invalid if the owner already has a list with that name' do
    o = create(:organisation)
    list_1 = create(:home_page_list, owner: o, name: 'contacts')
    list_2 = build(:home_page_list, owner: o, name: 'contacts')
    refute list_2.valid?
  end

  test 'adding a something to the list ensures it is added to the end of the list' do
    list = build(:home_page_list)
    item_1 = build(:home_page_list_item, home_page_list: list, ordering: nil)
    list.home_page_list_items << item_1
    refute item_1.ordering.nil?
    item_2 = build(:home_page_list_item, home_page_list: list, ordering: nil)
    list.home_page_list_items << item_2
    refute item_2.ordering.nil?
    assert item_1.ordering < item_2.ordering
  end

  test 'adding something that already has an ordering to the list doesn\'t change it' do
    list = build(:home_page_list)
    item_1 = build(:home_page_list_item, home_page_list: list, ordering: 12)
    list.home_page_list_items << item_1
    assert_equal 12, item_1.ordering
  end

  test 'exposes all the items in the home_page_list_items in order' do
    o = create(:organisation)
    contact_1 = create(:contact)
    contact_2 = create(:contact)
    contact_3 = create(:contact)
    list = create(:home_page_list, owner: o, name: 'contacts')
    list.home_page_list_items << build(:home_page_list_item, item: contact_2)
    list.home_page_list_items << build(:home_page_list_item, item: contact_3)
    list.home_page_list_items << build(:home_page_list_item, item: contact_1)

    assert_equal [contact_2, contact_3, contact_1], list.items
  end
end
