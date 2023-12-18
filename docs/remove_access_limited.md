# Access limited
Whitehall offers an “access limiting” feature on editions. This makes documents that are sensitive only viewable by the
owning organisation while in draft. This works by checking the edition organisations ids against the user's organisation id.

The access limited attribute can be set on the edition edit page. It is a check box near the bottom of the page.

# Know user issues and fixes

Sometimes users set an edition to be access limited, but are not members of the owning organisation so they can no longer
view the document, in this case (if the user agrees) we can make the document un-access-limited so it is viewable by everyone,
and it can be edited again.

A rake task was introduced to aid 2nd-line to temporarily remove the access.
It can be be used in the following way:

```
# Given an Edition of ID 12345
rake remove_access_limiting[12345]
```
