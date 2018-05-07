# language-startup-benchmark

When using a script, the speed the language starts up matters the most. Regardless of how fast it can process data, a language that starts up slower will end up slower for a simple script.

This project aims to run a simple benchmark with hello world for many languages.

## Running

Run `language-startup-benchmark` to time the interpreted languages, compile and time executables for compiled languages, and generate a json report under `_reports`. Run `process.rkt` with the `_reports` folder as the first argument to generate a .txt, a json, and a histogram picture report from the reports in that folder.

Sometimes some compiles will fail. Until I actually manage to fix it, just remove all reports with failures with `rm "$(grep failed _reports/* --files-with-match)"`.

Licensed under the MIT license.
