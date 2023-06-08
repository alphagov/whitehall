# PlantUML Diagrams

These diagrams are generated with [plantuml](http://plantuml.com/).

```
brew update
brew install plantuml
cd docs/diagrams
PLANTUML_LIMIT_SIZE=8192 plantuml *.puml
```

You can also use an IDE plugin, or run a server so you can edit the `.puml` files and the images will be live reloaded. See [the plantuml docs](https://plantuml.com/running) for more.

[As of Jan 2022 you can also use svg files](https://github.blog/changelog/2022-01-21-allow-to-upload-svg-files-to-markdown/) - SVG files are smaller, and scale better to allow large images to be shared.

`plantuml -tsvg *.puml` to generate them, embed them in markdown as normal:

`!(description for accessibility)[path_to_file.svg]`
