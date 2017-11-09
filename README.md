# unsafe
[![Coverage Status](https://img.shields.io/coveralls/whitfin/unsafe.svg)](https://coveralls.io/github/whitfin/unsafe) [![Unix Build Status](https://img.shields.io/travis/whitfin/unsafe.svg?label=unix)](https://travis-ci.org/whitfin/unsafe) [![Windows Build Status](https://img.shields.io/appveyor/ci/whitfin/unsafe.svg?label=win)](https://ci.appveyor.com/project/whitfin/unsafe) [![Hex.pm Version](https://img.shields.io/hexpm/v/unsafe.svg)](https://hex.pm/packages/unsafe) [![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://hexdocs.pm/unsafe/)

This library is designed at generating unsafe (!) bindings for Elixir
function definitions at compile time.

The aim is to reduce the amount of duplicated code that developers have
to write when supporting both safe and unsafe variants of functions. It
was written to scratch a personal itch but due to the clear utility for
a wider audience, it was packaged up to make it extensible as an open
source project.

To install it for your project, you can pull it directly from Hex. Rather
than use the version shown below, you can use the the latest version from
Hex (shown at the top of this README).

```elixir
def deps do
  [{:unsafe, "~> 1.0"}]
end
```

Documentation and examples can be found on [Hexdocs](https://hexdocs.pm/unsafe/)
as they're updated automatically alongside each release.
