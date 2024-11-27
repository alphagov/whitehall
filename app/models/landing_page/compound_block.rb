# Compound blocks are blocks which have some of their own configuration,
# alongside a list of child blocks. For example:
#
# - type: hero
#   image: ...
#   hero_content:
#     blocks:
#       - type: govspeak
#         content: some text
#
# hero blocks are Compound blocks because they have their own config (image) as
# well as children (hero_content -> blocks).
#
# Compound blocks have an extra key above the blocks (hero_content, featured_content, card_content etc.)
# This is referred to here as the "content_block_key"
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
