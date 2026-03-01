# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This App Does

PR Tracker is a personal fitness tracking app for logging workouts and identifying Personal Records (PRs) across rep ranges. Users paste raw workout text in two supported formats (Reddit Markdown or Weightroom.uk), which gets parsed into structured exercise sets. PRs are detected asynchronously via Sidekiq.

## Commands

```bash
bin/dev              # Start all dev processes (Rails, Dart Sass, Sidekiq) via Foreman
bin/setup            # Install gems, prepare DB, clear logs/tmp
bin/rails db:migrate # Run pending migrations
bin/rspec            # Run tests
bundle exec rspec spec/path/to/file_spec.rb  # Run a single test file
```

## Architecture

### Data Flow: Workout Parsing & PR Detection

1. User submits raw workout text via `WorkoutsController#create/update`
2. `Parser` service detects format (first line starting with `#` → WeightroomDotUk, otherwise RedditMarkdown) and delegates to the appropriate parser
3. Parsed `Parser::ExerciseSet` structs are persisted to the DB
4. `PrFinderWorker` (Sidekiq) is triggered asynchronously → calls `PrFinder.update`
5. `PrFinder` uses PostgreSQL CTEs and window functions to update `pr` and `latest_pr` boolean flags on `ExerciseSet` records, respecting exercise synonyms
6. Turbo Stream broadcasts update affected workout views in real time

### Models

- `Exercise` — self-referential synonym relationship via `synonym_of_id`; `benchmark_lift` boolean marks key lifts
- `ExerciseSet` — core data: `weight_lbs`, `reps`, `bodyweight`, `duration_seconds`, `pr`, `latest_pr`, `line_number`; has explicit `user_id` (denormalized from workout)
- `Workout` — unique constraint on `(date, user_id)`; stores `raw_text` for re-parsing
- `User` — Devise authentication

### Key Services (`app/services/`)

- `Parser` — dispatches to format-specific parsers; returns `Parser::Workout` struct
- `WeightroomDotUkParser` / `RedditMarkdownParser` — format parsers; unmatched lines are printed to stderr, not raised
- `PrFinder` — all PR logic lives here in raw SQL; handles synonyms by resolving to canonical exercise ID
- `ChartPresenter` — struct for chart data formatting

### Frontend

- **Views**: HAML with `.turbo_stream.haml` variants for Turbo Stream responses
- **CSS**: Bulma via Dart Sass (`dartsass-rails`); no npm/webpack
- **JS**: Stimulus controllers + Turbo via Rails importmap (no bundler)
- **Stimulus controllers**: `exercise-filter`, `exercise-search` in `app/javascript/controllers/`

### Background Jobs

Single Sidekiq worker: `PrFinderWorker` — no queue, retry, or timeout configuration. Redis is required in development (`redis://localhost:6379/1`).

## Deployment

Deployed on Render. See `render.yaml` for service definitions (web + Sidekiq worker + PostgreSQL + Redis). Production build runs `bin/render-build.sh`.
