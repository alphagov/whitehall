class LandingPage::BlockFactory
  def self.build_all(blocks, images)
    (blocks || []).map { build(_1, images) }
  end

  def self.build(block, images)
    case block.symbolize_keys
    in { type: "hero" }
      LandingPage::HeroBlock.new(block, images)
    else
      LandingPage::BaseBlock.new(block, images)
    end
  end
end
