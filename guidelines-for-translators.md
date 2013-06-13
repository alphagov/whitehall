Guidelines for translators
===============

These points should hopefully be useful for anyone performing label and type
translations.


Pluralisation
-----------

Some types are used in singular and plural forms, like "Policy" and "Policies".
These appear in the translation CSV as two different keys, for example:

    key,                         source,   translation
    document.types.policy.one,   Policy,   ...
    document.types.policy.other, Policies, ...

In simple cases, you should provide the singular translation against the 'one'
key, and the plural translation against the 'other' key. If your language has
multiple plural forms, we will need to produce additional keys for your
language. Please get in touch with GDS to arrange this.


Interpolated translations
-------------------------

Some translations include special codes which are replaced with content about
specific documents. For example, in the source

    key,           source,                    translation
    document.read, Read the %{title} article, ...

the string `%{title}` will be replaced with the title of a document. Your
translation should also include this `%{title}` code wherever it makes most
sense for a document title to appear. For example, in French the document title
is probably at the end of the translation:

    key,           source,                    translation
    document.read, Read the %{title} article, Lire l'article intitulé «%{title}»
