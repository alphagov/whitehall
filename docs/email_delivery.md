# Email delivery

Whitehall sends various kinds of [email notifications](https://github.com/alphagov/whitehall/blob/ad86a5ea8d7538f787c71cb586adb1b771ea08d9/app/mailers/mail_notifications.rb) to users – for example, fact check requests and responses. These emails are delivered via [GOV.UK Notify](https://www.notifications.service.gov.uk/) using the [mail-notify](https://github.com/dxw/mail-notify) gem.

## Non-production environments

Emails sent from Whitehall's integration and staging environments are not delivered to end users.

Instead, they're [intercepted and re-routed](https://github.com/alphagov/whitehall/pull/7240) to a Google Group (shared mailbox) so they can be accessed for debugging purposes. The intended recipient is prepended to the email body so it's easy to see who it would've been delivered to.

👉 [See emails from integration](https://groups.google.com/a/digital.cabinet-office.gov.uk/g/whitehall-emails-integration)

👉 [See emails from staging](https://groups.google.com/a/digital.cabinet-office.gov.uk/g/whitehall-emails-staging)

## Send a test email from the Rails console

> **⚠️ Warning**
> 
> Running this in **production** will send an email to the specified recipient.
> Use **integration or staging** if you want the email to be intercepted.

To send a test email, open a Rails console and run:

```ruby
ApplicationMailer.new.mail(
  subject: "Test email",
  to: "recipient@example.com",
  body: "This is a test email",
  template_id: ENV.fetch("GOVUK_NOTIFY_TEMPLATE_ID", "fake-test-template-id")
).deliver
```
