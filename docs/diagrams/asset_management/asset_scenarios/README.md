# Auto generated object diagrams
These diagrams are generated using commands in rails consoles:

## Whitehall objects

in a whitehall console
```rb
Document.all.map {|d| d.slice(:id, :content_id, :slug)}
# find the document ID you want then
DiagramGenerator::DocumentObjectDiagram.new(1).draw
```

then paste the plantuml code to a text file.

## Publishing API objects

in a Publishing API console:
```rb
Document.all.map {|d| d.slice(:id, :content_id) }
# find the document ID you want then
DiagramGenerator::DocumentObjectDiagram.new(1).draw
```

## AssetManager objects

Asset Manager has no direct mapping from Whitehall - instead `Asset::legacy_url_path` fields are used!

We can identify them though by the Model type, and the ID, from Whitehall.

For example a path like 
`/government/uploads/system/uploads/attachment_data/file/1/MyFile.pdf` comes from an `AttachmentData` model, with an ID of `1`

So you need to find the model objects, `AttachmentData` and `ImageData` and their `ID`s from the Whitehall diagram above.

then in an Asset manager console:
```rb
# show all legacy urls - for some reason `slice` doesn't work:
Asset.all.map {|x| [x.id, x.legacy_url_path]}

# assuming we want all assets for AttachmentData with id 1:
DiagramGenerator::ObjectDiagram.new("AttachmentData",1).draw
```

## Pausing sidekiq

Another neat thing you can do to capture intermediate state is to pause sidekiq.

If you are developing in Docker this is very easy - just pause the worker image:

```sh
govuk-docker pause whitehall-worker
# do stuff and capture state
govuk-docker unpause whitehall-worker
# capture state after background workers run
```
