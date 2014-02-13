require "test_helper"

class Edition::NationInapplicabilityTest < ActiveSupport::TestCase
  setup do
    @nation_inapplicability = create(:nation_inapplicability, nation_id: 2)
    @edition = create(:draft_policy, nation_inapplicabilities: [@nation_inapplicability])
  end

  test "#destroy should also remove the relationship" do
    relation = @edition.nation_inapplicabilities.first
    @edition.destroy

    refute NationInapplicability.find_by_id(relation.id)
  end

  test "mass-assignment of nation inapplicabilities creates new exclusions" do
    @edition.nation_inapplicabilities_attributes = nation_inapplicability_attributes_for(nation_id: '3', alternative_url: 'http://wales.org')

    assert @edition.save
    assert_equal 2, @edition.nation_inapplicabilities.size

    assert_equal Nation::Scotland, @edition.nation_inapplicabilities[0].nation
    assert_nil @edition.nation_inapplicabilities[0].alternative_url
    assert_equal Nation::Wales, @edition.nation_inapplicabilities[1].nation
    assert_equal 'http://wales.org', @edition.nation_inapplicabilities[1].alternative_url
  end

  test "mass-assignment of nation inapplicabilities updates existing exclusions" do
    @edition.nation_inapplicabilities_attributes = nation_inapplicability_attributes_for(nation_id: '2', id: @nation_inapplicability.to_param, alternative_url: 'http://scotland.org')

    assert @edition.save
    assert_equal 1, @edition.nation_inapplicabilities.size

    assert_equal Nation::Scotland, @edition.nation_inapplicabilities[0].nation
    assert_equal 'http://scotland.org', @edition.nation_inapplicabilities[0].alternative_url
  end

  test "mass-assignment of nation inapplicabilities removes existing exclusions" do
    @edition.nation_inapplicabilities_attributes = nation_inapplicability_attributes_for(excluded: '0', nation_id: '2', id: @nation_inapplicability.to_param, alternative_url: 'http://scotland.org')

    assert @edition.save
    assert_equal 0, @edition.nation_inapplicabilities.size
  end

  test "mass-assignment of nation inapplicabilities maintains excluded state" do
    assert @edition.nation_inapplicabilities.first.excluded?

    @edition.nation_inapplicabilities_attributes = nation_inapplicability_attributes_for(excluded: '0', nation_id: '2', id: @nation_inapplicability.to_param, alternative_url: 'http://scotland.org')

    refute @edition.nation_inapplicabilities[0].excluded?
  end

  def nation_inapplicability_attributes_for(*attributes)
    # Turns a hash of attributes (or an array of hashes of attributes) into a hash that resembles the equivelant
    # form field params, e.g. { '0' => { param1: 'val', param2: 'val2'}, '1' => { param3: 'val'} }
    Hash[*attributes.each_with_index.map { |attribs, i| [i.to_s, { excluded: '1' }.merge(attribs)]  }.flatten]
  end
end