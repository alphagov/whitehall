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

  test '#shown_on_home_page? tells us if a given thing is in the list or not' do
    list = create(:home_page_list)
    contact_1 = create(:contact)
    contact_2 = create(:contact)
    list.home_page_list_items << build(:home_page_list_item, item: contact_1)

    assert list.shown_on_home_page?(contact_1)
    refute list.shown_on_home_page?(contact_2)
  end

  test '#add_item will put the supplied item onto the list' do
    list = create(:home_page_list)
    contact = create(:contact)
    list.add_item(contact)

    assert list.home_page_list_items.where(item_id: contact.id, item_type: contact.class).any?
  end

  test '#add_item will not duplicate an item that is already on the list' do
    list = create(:home_page_list)
    contact = create(:contact)
    list.home_page_list_items << build(:home_page_list_item, item: contact)
    list.add_item(contact)

    assert_equal 1, list.home_page_list_items.where(item_id: contact.id, item_type: contact.class).length
  end

  test '#add_item will persist the list' do
    list = build(:home_page_list)
    contact = create(:contact)
    list.add_item(contact)

    assert list.persisted?
  end

  test '#remove_item will take an idem off the list' do
    list = create(:home_page_list)
    contact = create(:contact)
    list.home_page_list_items << build(:home_page_list_item, item: contact)
    list.remove_item(contact)

    refute list.home_page_list_items.where(item_id: contact.id, item_type: contact.class).any?
  end

  test '#remove_item won\'t complain if the supplied item isn\'t already on the list' do
    list = create(:home_page_list)
    contact = create(:contact)
    assert_nothing_raised { list.remove_item(contact) }
  end

  test '#remove_item will persist the list' do
    list = build(:home_page_list)
    contact = create(:contact)
    list.remove_item(contact)

    assert list.persisted?
  end

  test '.get will return the list for the supplied owned_by: and called: params' do
    o = create(:organisation)
    list_1 = create(:home_page_list, owner: o, name: 'donkeys')
    list_2 = create(:home_page_list, owner: o, name: 'cats')
    list_3 = create(:home_page_list, owner: create(:organisation), name: 'cats')

    assert_equal list_2, HomePageList.get(owned_by: o, called: 'cats')
  end

  test '.get will build a new list for the supplied owned_by: and called: params if one does not exist already' do
    o = create(:organisation)

    list = HomePageList.get(owned_by: o, called: 'cats')
    refute list.persisted?
    assert_equal o, list.owner
    assert_equal 'cats', list.name
  end

  test '.get will not build a new list if told not to' do
    o = create(:organisation)

    list = HomePageList.get(owned_by: o, called: 'cats', build_if_missing: false)
    assert_nil list
  end

  test '.get will raise ArgumentError if owned_by: and called: are not both present' do
    assert_raise(ArgumentError) { HomePageList.get() }
    assert_raise(ArgumentError) { HomePageList.get(owned_by: create(:organisation)) }
    assert_raise(ArgumentError) { HomePageList.get(called: 'cates') }
  end

  test '#reorder_items! takes a list of items and reorders the existing list' do
    list = create(:home_page_list)
    contact_1 = create(:contact)
    contact_2 = create(:contact)
    contact_3 = create(:contact)
    list.home_page_list_items << build(:home_page_list_item, item: contact_1)
    list.home_page_list_items << build(:home_page_list_item, item: contact_2)
    list.home_page_list_items << build(:home_page_list_item, item: contact_3)

    list.reorder_items!([contact_2, contact_3, contact_1])

    assert_equal [contact_2, contact_3, contact_1], list.reload.items
  end

  test '#reorder_items! puts any existing items not mentioned in the new ordering at the end of the list' do
    list = create(:home_page_list)
    contact_1 = create(:contact)
    contact_2 = create(:contact)
    contact_3 = create(:contact)
    list.home_page_list_items << build(:home_page_list_item, item: contact_1)
    list.home_page_list_items << build(:home_page_list_item, item: contact_2)
    list.home_page_list_items << build(:home_page_list_item, item: contact_3)

    list.reorder_items!([contact_2, contact_3])

    assert_equal [contact_2, contact_3, contact_1], list.reload.items
  end

  test '#reorder_items! ignores any items not already in the list' do
    list = create(:home_page_list)
    contact_1 = create(:contact)
    contact_2 = create(:contact)
    contact_3 = create(:contact)
    list.home_page_list_items << build(:home_page_list_item, item: contact_1)
    list.home_page_list_items << build(:home_page_list_item, item: contact_3)

    list.reorder_items!([contact_2, contact_3, contact_1])

    assert_equal [contact_3, contact_1], list.reload.items
  end

  test '#reorder_items! will persist the list' do
    list = build(:home_page_list)
    contact = create(:contact)
    list.reorder_items!([contact])

    assert list.persisted?
  end

  test '.remove_from_all_lists destroys all list items for the supplied content' do
    list_1 = create(:home_page_list, name: 'contacts')
    list_2 = create(:home_page_list, name: 'press_offices')
    contact_1 = create(:contact)
    contact_2 = create(:contact)
    list_1.add_item(contact_1)
    list_1.add_item(contact_2)
    list_2.add_item(contact_1)

    HomePageList.remove_from_all_lists(contact_1)

    # removes from all lists it's on
    refute list_1.shown_on_home_page?(contact_1)
    refute list_2.shown_on_home_page?(contact_1)

    # doesn't remove other items
    assert list_1.shown_on_home_page?(contact_2)
  end
end
