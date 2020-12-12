# Package

version       = "0.0.1"
author        = "Samuel Beckingham-Cook"
description   = "Generate a static web book from markdown"
license       = "GNU GPLv3"

# Source

srcDir        = "src"
bin           = @["nimbuk"]


# Dependencies

requires "nim >= 1.4.2"
requires "markdown >= 0.8.0"
requires "cligen >= 1.3.2"