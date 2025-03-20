# Deleting a content block

## Before deleting

* Are you sure you need to delete the content block? 
* Have you had sign off from the team that deleting is the best way forward?
* Is the content block in use anywhere?

If the content block is in use anywhere - then you MUST first remove the content block reference
from all of the dependent documents and replace it with static text. The deletion task will fail
if the block is still referenced anywhere.

## How to delete a content block

Run the following command in the `whitehall-admin` Kubernetes (where `CONTENT_ID` is the content_id of the 
block you want to delete):

```bash
rake "content_block_manager:delete_content_block[CONTENT_ID]"
```

For example:

```bash
kubectl exec -it deploy/whitehall-admin -- rake "content_block_manager:delete_content_block[a2184d5d-9d3a-4fc3-a290-8bb00edbfb69]"
```

This will then "Unpublish" the block and all its editions in Publishing API, as well as soft delete the block in
Content Block Manager, so it remains in the database for audit purposes, but does not show in the UI.
