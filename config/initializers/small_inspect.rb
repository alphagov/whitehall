# The view context is so large that in some cases (eg. when an exception is raised
# in a template where multiple presenters are referencing the view_context), the
# ruby process spins out eating more and more memory before either generating an
# enormous half-gig log or falling over altogether. This commit suppresses
# inspect messages on ActionView::Base allowing exceptions to raise without issue.
#
# More info on the issue here: https://github.com/rails/rails/issues/1525#issuecomment-1623635

module SmallInspect
  def inspect
    "<#{self.class.name || "An anonymous class"} is too large to inspect, supressing>"
  end
end

ActionView::Base.send(:include, SmallInspect)
