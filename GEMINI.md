# Gemini Project: sbwi-schedule

## Project Overview

This is a tool, written in ruby, to synchronise the schedule of continuing eduction classes listed on the Sam Beauford
Woodworking Institute's (SBWI) website to a Google calendar. The tool is executed with the command `bundle exec sbwi-sync.rb`.

## Building and Running

To run the program
```bash
bundle exec sbwi-sync.rb
```

To run tests:
```bash
bundle exec rake test
```

## Development Conventions

*   **Language:** Ruby
*   **Testing:** TDD using Minitest
*   **Dependencies:** Managed via Bundler