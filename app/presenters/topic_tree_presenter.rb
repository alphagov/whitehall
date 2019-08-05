class TopicTreePresenter < SimpleDelegator
  attr_reader :collapsed

  def initialize(taxon, collapsed: false)
    @collapsed = collapsed
    super(taxon)
  end

  def toggle_classes
    toggle_classes = %w[taxon-name]
    toggle_classes << "collapsed" if collapsed
    toggle_classes.join(" ")
  end

  def tree_classes
    tree_classes = %w[collapse level-one-taxon]
    tree_classes << "in" unless collapsed
    tree_classes.join(" ")
  end
end
