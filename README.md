# Treefmt path traversal issue

## Steps to reproduce

1. Run `treefmt bin` and notice that no files are processed.

2. Run `treefmt` (no path provided) and see that `bin/a` is now formatted.

## Expected behaviour

I would expect these two invocations to be equivalent and `bin/a` to be formatted by either. I suspect this is to do with the `includes` glob for `bin/*` not being applied when the subpath is specified.
