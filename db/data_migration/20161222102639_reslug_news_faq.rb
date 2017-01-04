article = NewsArticle.find(688810)
document = article.document

document.update_attributes(slug: "information-about-the-uk-leaving-the-eu")
