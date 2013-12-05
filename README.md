### Seamlessly edit an html file using markdown. ###

**H**TML **a**s **M**arkdown.

This package defines a major-mode, `ham-mode`, which allows you to
edit HTML files exactly as if they were Markdown files. Activate it
while visiting an HTML file. The buffer will be converted to Markdown,
but the file will still be kept in HTML format behind the scenes.
 
Instructions
------

To use this package, simply:

1. Install it from Melpa (`M-x package-install RET ham-mode`) and the
`ham-mode` command will be autoloaded.
2. Activate it inside any HTML files you'd like to edit as Markdown.
You can manually invoke `M-x ham-mode`, or add it to `auto-mode-alist`
so that it can load automatically.
