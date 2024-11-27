class LandingPage::BlockFactory
  def self.build_all(blocks, images)
    (blocks || []).map { build(_1, images) }
  end

  def self.build(block, images)
    case block.symbolize_keys
    in { type: "box", box_content: }
      LandingPage::CompoundBlock.new(block, images, "box_content", box_content)
    in { type: "card", card_content: }
      LandingPage::CompoundBlock.new(block, images, "card_content", card_content)
    in { type: "featured", featured_content: }
      LandingPage::CompoundBlock.new(block, images, "featured_content", featured_content)
    in { type: "hero", hero_content: }
      LandingPage::HeroBlock.new(block, images, hero_content)
    in { type: String, blocks: Array }
      LandingPage::ParentBlock.new(block, images)
    else
      LandingPage::BaseBlock.new(block, images)
    end
  end
end
