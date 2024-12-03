require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::HostEditionsRollupComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:described_class) { ContentBlockManager::ContentBlock::Document::Show::HostEditionsRollupComponent }

  it "returns rolled up data with small numbers" do
    rollup = build(:rollup, views: 12, locations: 2, instances: 3, organisations: 1)

    render_inline(described_class.new(rollup:))

    assert_selector ".rollup-details__rollup-metric.views .gem-c-glance-metric__heading", text: "Views"
    assert_selector ".rollup-details__rollup-metric.views .gem-c-glance-metric__figure", text: "12"

    assert_selector ".rollup-details__rollup-metric.locations .gem-c-glance-metric__heading", text: "Locations"
    assert_selector ".rollup-details__rollup-metric.locations .gem-c-glance-metric__figure", text: "2"

    assert_selector ".rollup-details__rollup-metric.instances .gem-c-glance-metric__heading", text: "Instances"
    assert_selector ".rollup-details__rollup-metric.instances .gem-c-glance-metric__figure", text: "3"

    assert_selector ".rollup-details__rollup-metric.organisations .gem-c-glance-metric__heading", text: "Organisations"
    assert_selector ".rollup-details__rollup-metric.organisations .gem-c-glance-metric__figure", text: "1"
  end

  it "returns rolled up data with larger numbers" do
    rollup = build(:rollup, views: 12_000_000, locations: 15_000)

    render_inline(described_class.new(rollup:))

    assert_selector ".rollup-details__rollup-metric.views .gem-c-glance-metric__heading", text: "Views"
    assert_selector ".rollup-details__rollup-metric.views .gem-c-glance-metric__figure", text: "12"
    assert_selector ".rollup-details__rollup-metric.views .gem-c-glance-metric__display-label", text: "m"
    assert_selector ".rollup-details__rollup-metric.views .gem-c-glance-metric__explicit-label", text: "Million"

    assert_selector ".rollup-details__rollup-metric.locations .gem-c-glance-metric__figure", text: "15"
    assert_selector ".rollup-details__rollup-metric.locations .gem-c-glance-metric__display-label", text: "k"
    assert_selector ".rollup-details__rollup-metric.locations .gem-c-glance-metric__explicit-label", text: "Thousand"
  end
end
