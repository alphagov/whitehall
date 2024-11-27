class LandingPage::CompoundBlock < LandingPage::BaseBlock
  include ActiveModel::API

  attr_reader :content_blocks, :content_block_key

  validates :content_blocks, presence: true
  validate do
    content_blocks.each { |b| errors.merge!(b.errors) if b.invalid? }
  end

  def initialize(source, images, content_block_key, content_blocks)
    super(source, images)
    @content_block_key = content_block_key
    @content_blocks = LandingPage::BlockFactory.build_all(content_blocks, images)
  end

  def present_for_publishing_api
    super.merge({ content_block_key => { "blocks" => content_blocks.map(&:present_for_publishing_api) } })
  end
end
