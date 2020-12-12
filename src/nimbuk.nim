import markdown

proc build(path = "src") =
    let contents = readFile(path & "/contents.md")
    let html = markdown(contents)
    writeFile("test.html", html)

when isMainModule:
  import cligen
  dispatchMulti([build])