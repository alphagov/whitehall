class LandingPage::BlockFactory
  def self.build_all(blocks, images)
    (blocks || []).map { build(_1, images) }
  end

  def self.build(block, images)
    case block.with_indifferent_access
    in { type: "box" }
      LandingPage::CompoundBlock.new(block, images, "box_content")
    in { type: "card" }
      LandingPage::CompoundBlock.new(block, images, "card_content")
    in { type: "featured" }
      LandingPage::FeaturedBlock.new(block, images)
    in { type: "hero" }
      LandingPage::HeroBlock.new(block, images)
    in { type: "image" }
      LandingPage::ImageBlock.new(block, images)
    in { type: String, blocks: Array }
      LandingPage::ParentBlock.new(block, images)
    else
      LandingPage::BaseBlock.new(block, images)
    end
  end
end
