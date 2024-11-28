class LandingPage::BlockFactory
  def self.build_all(blocks, images)
    (blocks || []).map { build(_1, images) }
  end

  def self.build(block, images)
    case block.with_indifferent_access
    in { type: "box", box_content: { blocks: } }
      LandingPage::CompoundBlock.new(block, images, "box_content", blocks)
    in { type: "card", card_content: { blocks: } }
      LandingPage::CompoundBlock.new(block, images, "card_content", blocks)
    in { type: "featured", featured_content: { blocks: } }
      LandingPage::FeaturedBlock.new(block, images, blocks)
    in { type: "hero", hero_content: { blocks: } }
      LandingPage::HeroBlock.new(block, images, blocks)
    in { type: "image" }
      LandingPage::ImageBlock.new(block, images)
    in { type: String, blocks: Array }
      LandingPage::ParentBlock.new(block, images)
    else
      LandingPage::BaseBlock.new(block, images)
    end
  end
end
