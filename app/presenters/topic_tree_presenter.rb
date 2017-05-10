class TopicTreePresenter < SimpleDelegator
  attr_reader :collapsed

  def initialize(taxon, collapsed: false)
    @collapsed = collapsed
    super(taxon)
  end

  def toggle_classes
    toggle_classes = ["taxon-name"]
    toggle_classes << "collapsed" if collapsed
    toggle_classes.join(" ")
  end

  def tree_classes
    tree_classes = ["collapse"]
    tree_classes << "in" unless collapsed
    tree_classes.join(" ")
  end
end
