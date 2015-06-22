Pending migration cleanups

In order to avoid breaking things when doing schema migrations, we'll try to
do non-destructive database migrations as far as possible. These will add new
columns but not remove old ones. The pending migration cleanups are to serve
as a reminder to delete these columns once the initial migration has been
successfully deployed to production.
