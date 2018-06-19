# installed-font-list-html
Make HTML listed installed fonts and samples.

# Usage

```
installed-font-list-html.rb [-m|-d] [-H] [-j] [-o outfile]
```

# Dependency

* FontConfig
* Ruby

# Options

## `-m`

List only monospace fonts.

## `-d`

List monospace and dualspace fonts.

It means including east Asian monospaced fonts,
but it may include proportional font because some proportional font has spacing `90`.

## `-j`

Exclude not kana capable font.

*CAUTION: some font capable kana but doesn't have kana glyph or some font not capable kana but has kana glyph.*

## `-h`

Exclude not hani capable font.

*CAUTION: some font capable han but doesn't have han glyph or some font not capable han but has han glyph.*

## `-o outfile`

Internal redirect STDOUT to outfile.

## Notice

This program depends web rendering. It may not work on some fonts.

If font not have suitable glyph, some web browser takes other font for the glyph.
