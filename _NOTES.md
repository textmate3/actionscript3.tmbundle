# Notes from test suite modernization (2026-08-20)

Findings from modernizing this bundle's test suite

The suite is a custom `suite.rb` runner over 18 case files covering the `FlexMate` build system (`fm/`) and the ActionScript 3 tooling (`as3/`), including parsers for classes, interfaces, manifests, MXML, and binary SWF (Shockwave Flash) files.

## Result

```sh
ruby Support/test/suite.rb
# 107 tests, 576 assertions, 100%
```

The suite self-configures: it puts `Support/lib` on the load path and defaults `TM_SUPPORT_PATH` to the sibling `bundle-support.tmbundle` checkout, so it runs from any working directory. It previously required launching from inside TextMate with Apple-R. Baseline before this quest was 55% passing (25 failures, 23 errors).

## What was broken and since when

**Ruby 1.9 semantic drift (2007), three species:**

- `String#each` removed: nine sites in `class_parser.rb` iterated document bodies and the newline-delimited `@src_dirs` list 1.8-style. Fixed with `each_line`. This alone cut 20 tests short.
- `String#[]` and `slice!` returned `Integer` bytes in 1.8 but 1-character `Strings` since 1.9: the SWF binary parser fed characters to `sprintf` where it needed byte values. Fixed with `.ord`, plus `File.binread` replacing a text-mode read that corrupted the compressed body. The parser also had a since created latent bug computing an alpha channel from a byte that a `SetBackgroundColor` tag never carries.
- `Array#to_s` stopped meaning "`join`": `property_inspector.rb` reassembled scanned characters with `to_s`, so every property chain lookup returned an inspect string and then nil. All 15 `TestPropertyInspector` failures had this one root cause. The source tools tests used the same idiom in assertions.

**Invisible environment contracts (tests assuming variables and machine state that only exist in-editor):**

- `test_config`: `ConfigUtil#find` reads `TM_PROJECT_DIRECTORY` and raised on `nil`. Pinned in setup with teardown restore. The library itself still has `ENV['TM_PROJECT_DIRECTORY']+'/' || ''` with the uselessly bound or, working in-editor only because TextMate always sets the variable.
- `test_class_parser`: `load_class` discovers source directories by running find under `TM_PROJECT_DIRECTORY`. In the editor the bundle itself was the project, which put the fixture class tree `assets/cp/src` in scope at exactly find's depth limit. Pinned to the fixture tree.
- `test_bundle_tool`: probed the real `~/Library` for installed Flex and ActionScript 3 bundles. Now points `HOME` at a fixture home, the ruby.tmbundle `fake_rvm_home` pattern.
- `test_asd`: the language reference tests need locally installed 2009-era Adobe documentation. The file's own convention is `return unless can_test`, and exactly the two failing tests had forgotten the guard.

**Stale expectations against evolved data (2010 tests, 2011 data):** the documentation dictionary gained Flex 4 `spark` classes in June 2011 after the source tools tests were written in March 2010, so expected match lists and counts no longer matched the bundle's own shipped data. Expectations refreshed.

**A literal time bomb:** the template machine stamps the current year into copyright banners via `date +%Y`, ignoring the `TM_YEAR` the test pinned. The banner tests last passed on December 31, 2010. The library now honors `TM_YEAR` when set, which is what the test author clearly assumed.

**Git cannot track empty directories:** `Settings#flex_output` substitutes `src` with `bin` only when the project has a `bin` directory. The `Test/project/d/bin` fixture directory was empty, so it vanished on clone and the test failed forever after. Restored with a `.gitkeep`.

## Observations, left unchanged

- Frozen string literal warnings remain in `manifest.rb`, `mxml.rb`, and `suite` runs (Ruby 4.0 direction, not yet failing).
- A stray `ps: Invalid process id` line prints during `fm` tests, from process-check code shelling out with garbage input. Harmless noise, not investigated.
- `class_parser.rb` line 87: `@buffer.slice!(0..3).unpack('v')` reads only 16 of the SWF file length's 32 bits. Works for small files, including the fixture.
- The `Test/project` fixture README documents the build-test projects. And `settings.rb` grew no new coverage.
