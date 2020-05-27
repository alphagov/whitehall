article = NewsArticle.find(688_810)
document = article.document

document.update!(slug: "information-about-the-uk-leaving-the-eu")
