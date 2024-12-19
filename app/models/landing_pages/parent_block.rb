class LandingPages::ParentBlock < LandingPages::BaseBlock
  attr_reader :blocks

  validate do
    blocks.each { |b| errors.merge!(b.errors) if b.invalid? }
  end

  def initialize(source, images)
    super(source, images)

    @blocks = LandingPages::BlockFactory.build_all(source["blocks"], images)
  end

  def present_for_publishing_api
    super.merge("blocks" => blocks.map(&:present_for_publishing_api))
  end
end
