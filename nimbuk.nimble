# Package

version       = "0.0.2"
author        = "Samuel Beckingham-Cook"
description   = "Generate a static web book from markdown"
license       = "GNU GPLv3"

# Source

srcDir        = "src"
bin           = @["nimbuk"]

# Dependencies

requires "nim >= 1.4.2"
requires "cligen >= 1.3.2"
requires "markdown >= 0.8.0"
requires "npeg >= 0.24.0"