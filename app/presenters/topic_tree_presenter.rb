class TopicTreePresenter < SimpleDelegator
  def initialize(taxon, number_of_taxonomies)
    @number_of_taxonomies = number_of_taxonomies
    super(taxon)
  end

  def toggle_classes
    toggle_classes = ["taxon-name"]
    toggle_classes << "collapsed" if @number_of_taxonomies > 1
    toggle_classes.join(" ")
  end

  def tree_classes
    tree_classes = ["collapse"]
    tree_classes << "in" if @number_of_taxonomies == 1
    tree_classes.join(" ")
  end
end
