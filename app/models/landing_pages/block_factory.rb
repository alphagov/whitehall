class LandingPages::BlockFactory
  def self.build_all(blocks, images)
    (blocks || []).map { build(_1, images) }
  end

  def self.build(block, images)
    case block.with_indifferent_access
    in { type: "box", box_content: { blocks: } }
      LandingPages::CompoundBlock.new(block, images, "box_content", blocks)
    in { type: "card", card_content: { blocks: } }
      LandingPages::CompoundBlock.new(block, images, "card_content", blocks)
    in { type: "featured", featured_content: { blocks: } }
      LandingPages::FeaturedBlock.new(block, images, blocks)
    in { type: "hero", hero_content: { blocks: } }
      LandingPages::HeroBlock.new(block, images, blocks)
    in { type: "hero" }
      LandingPages::HeroBlock.new(block, images, nil)
    in { type: "image" }
      LandingPages::ImageBlock.new(block, images)
    in { type: "govspeak" }
      LandingPages::GovspeakBlock.new(block, images)
    in { type: String, blocks: Array }
      LandingPages::ParentBlock.new(block, images)
    else
      LandingPages::BaseBlock.new(block, images)
    end
  end
end
