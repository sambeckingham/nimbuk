import htmlparser, markdown, npeg, os, strformat, strtabs, strutils, system,
    tables, xmltree
from htmlgen import html

proc createInitialBook =
  writeFile("src/nb_CONTENTS.md", "# Table of Contents\n\n- [Chapter 1](./chapter-1.md)")
  writeFile("src/chapter-1.md", "# Chapter 1")

proc parseLinkedPages(contentsPage: string): Table[string, string] =
  var pages: Table[string, string]

  let linkParser = peg contentLinks:
    contentLinks <- +contentLink
    contentLink <- @"- " * link
    link <- '[' * >title * "](./" * >path * ')': pages[$1] = $2
    title <- +(Alnum * ?Space)
    path <- +{'A'..'Z', 'a'..'z', '0'..'9', '.', '/', '-', '_'}

  discard linkParser.match(contentsPage)
  return pages

# TODO: The title grammar doesn't cover enough characters
doAssert parseLinkedPages("- [Test](./test.md)") == {"Test": "test.md"}.toTable
doAssert parseLinkedPages("- [Test Spaces](./test.md)") == {
    "Test Spaces": "test.md"}.toTable
doAssert parseLinkedPages("- [Test Caps 1](./Caps_n-Numz0123456789.md)") == {
    "Test Caps 1": "Caps_n-Numz0123456789.md"}.toTable
doAssert parseLinkedPages("- [Test](./test.md)\n- [Boop](./flurb.md)") == {
    "Test": "test.md", "Boop": "flurb.md"}.toTable

# TODO: Probably need to pull this into it's own module as part of the whole page boiler plate
proc parseAndReplaceLinks(contentsPage: var string) =
  var html = parseHtml html(contentsPage)

  for node in html.findAll("a"):
    if node.attrs.hasKey "href":
      let (dir, filename, ext) = splitFile(node.attrs["href"])
      if cmpIgnoreCase(ext, ".md") == 0:
        node.attrs["href"] = dir / filename & ".html"

  contentsPage = $html

proc initialiseMissingPages(pages: Table[string, string], path: string) =
  for page in pages.pairs:
    # TODO: Does not create sub folders, need to split page[1] and create dir
    let pagePath = &"{path}/{page[1]}"
    if not fileExists(pagePath):
      writeFile(pagePath, &"# {page[0]}")

proc build(path = "src") =
  if not fileExists(path & "/nb_CONTENTS.md"):
    echo "No content page found.  Have you run nimbuk init yet?"
    return

  let contentsPageMD = readFile(path & "/nb_CONTENTS.md")
  var pages = parseLinkedPages(contentsPageMD)
  initialiseMissingPages(pages, path)

  if not dirExists "out":
    createDir "out"

  var contentsHTML = markdown(contentsPageMD)
  parseAndReplaceLinks contentsHTML

  writeFile("out/index.html", contentsHTML)

  for page in pages.pairs:
    let pagePath = &"{path}/{page[1]}"
    let pageMD = readFile pagePath
    let pageHTML = markdown(pageMD)

    let (dir, filename, _) = splitFile(page[1])
    writeFile(&"out/{dir}/{fileName}.html", pageHTML)

proc init =
  if not dirExists "src":
    createDir "src"
  createInitialBook()

when isMainModule:
  import cligen
  dispatchMulti([build], [init])
