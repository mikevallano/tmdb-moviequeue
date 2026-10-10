# Discover v1 — Claude-powered movie suggestions

Admin-only page for finding movies to add to lists. One-shot: you give it a list, some text, or both, and get back about 10 real TMDB movies shown as normal movie cards.

## Scope

**In v1**
- An optional list picker plus an optional free-text box. At least one is required.
- Audience: when a list is selected, the list's owner plus its members. With no list, just the current user.
- Context sent to Claude: the request, the list's movies, each person's watch history and ratings (labeled per person), and the exclusions.
- Every title Claude returns is checked against TMDB, and duplicates and excluded movies are dropped.
- Labels on cards: "On 2 Soon," "Last watched 2019," "Your wife watched this in March."

**Not in v1**
- Follow-up refinement (conversation state)
- Claude using tools to search TMDB itself
- Runtime filtering (needs a TMDB details call per movie)
- Generated taste profile
- Streaming availability, for both Discover and lists (a separate feature)
- Showing Claude's `reason` (it's requested and stored on the entity, just not shown yet)

## Request flow

```
GET /suggestions                 -> form (list picker, text box)
GET /suggestions?list_id=..&q=.. -> same page, with results rendered below the form
```

A GET with params keeps it simple: no lazy frames or jobs, Turbo shows its progress bar during the wait, and the submit button uses `data-turbo-submits-with="Thinking…"`. Calls take a few seconds, which is fine for an admin page.

1. **Build context** (`MovieSuggestionService::Context`)
2. **Ask Claude** (`Claude::Client`) and get structured JSON back
3. **Check each suggestion against TMDB** (`MovieSuggestionService.ground`)
4. **Apply exclusions and labels, then sort**
5. **Render** with the existing `movies/_movie_partial_loop`

## Components

### Route and controller
- `get 'suggestions', to: 'suggestions#index', as: :movie_suggestions`. The route name `discover_search` is already used by TMDB's advanced search, so "Discover" is only the page title and nav label.
- `SuggestionsController < ApplicationController` with `before_action :restrict_to_admin!` on the whole controller. This is only the second use of the existing helper ([application_controller.rb:11](../app/controllers/application_controller.rb#L11)).
- Add the nav link only when `current_user.admin?`.

### `Claude::Client` (app/lib/claude/client.rb)
A thin wrapper so the rest of the app never talks to the SDK directly, and so specs can stub one method (`request_json`), the same way they stub `Tmdb::Client.request` today.
- Gem: `anthropic` (official Ruby SDK).
- Key: `ENV['anthropic_api_key']` through Figaro, passed explicitly as `Anthropic::Client.new(api_key: ...)` to match the `tmdb_api_key` convention.
- Model: `claude-opus-5-5`, kept in a constant. Effort: `medium` (the model's default), set explicitly so it's easy to tune.
- Structured output: `output_config.format` with a JSON schema. Confirm the Ruby SDK's exact binding when implementing, since the bundled docs don't show a Ruby example.
- Turn on server-side refusal fallbacks (`fallbacks: "default"`), then check `stop_reason` before parsing. A refusal is very unlikely for movie suggestions, but it should show a friendly error instead of raising.
- Log `usage.input_tokens` and `usage.output_tokens` per call to `Rails.logger` (tagged `[claude]`). That's enough to see cost.
- Skip prompt caching in v1. The stable prefix (system prompt) is probably below the minimum cacheable size, and it's one call per page load anyway.

### `MovieSuggestionService` (app/services/movie_suggestion_service.rb)
A module with class methods, following the existing services pattern.

**Context building**
- **Audience:**
  - A list is selected: `([list.owner] + list.members).uniq`. In practice this is the two of you.
  - No list: `[current_user]`.
- **Per person:**
  - Watched movies with their most recent `date_watched` and watch count (`Screening.by_user`)
  - Ratings (`Rating.by_user`)
  - Picked out of those: top-rated, lowest-rated, most rewatched, and watched in the last 6 months
  - Titles and years only, kept compact
- **List context:** the list name, description and its movies (title and year).
- **Exclusions sent in the prompt:** movies already on the selected list, and movies watched by *everyone* in the audience in the past 12 months.

**Prompt shape**
- System prompt (stable): the role, the priority order (the request comes first and taste only shapes choices within it), the instruction to return real theatrical releases with exact titles and release years, the instruction to avoid the excluded titles, and to return 12 suggestions (a few extra so some can be dropped).
- User message: sections for the request, the list, each person's taste, and the exclusions.
- If free text says something like "comfort rewatches," the prompt tells Claude it may override the default preference for unseen movies. The code-level 12-month rule still applies in v1.

**JSON schema**
```json
{ "suggestions": [ { "title": "string", "year": 1999, "reason": "string" } ] }
```

**TMDB check**
- For each suggestion, call `Tmdb::Client.request(:movie_search, query: title)[:results]` and pick the result whose `release_date` year matches (±1). If nothing matches, drop it.
- Build `MovieSearchResult` entities from the matched results. `_movie_partial_loop` only needs `tmdb_id` and `poster_path`, and the modal already calls `GuaranteedMovie.find_or_initialize_from_api` on click. Cost: **one TMDB call per suggestion**.
- Wrap each in a `MovieSuggestion` entity (app/entities): the search result plus `reason` and `labels`.
- Dedupe by `tmdb_id`, and remove anything on the selected list.
- **Hard exclude in code:** movies watched by everyone in the audience in the past 12 months. Claude can't be relied on to apply this rule every time.
- **Labels:** look up `Movie.where(tmdb_id: ids)` once, then the user's lists (via `List.by_user`) and each audience member's latest screening.
- **Sort:** new to everyone first, then labeled ones. Keep Claude's order within each group.
- Show at most 10.

### Views
- `suggestions/index.html.erb`:
  - The form: a list `select` from `List.by_user(current_user)`, a text area and the submit button.
  - Results: rendered through `movies/_movie_partial_loop`.
- Labels need a small addition, either an optional `labels` local on the partial or a thin wrapper partial. Don't fork the card.
- Set `@list` when a list is selected so the modal's "add to list" defaults to it (the partial reads `@list&.id`).
- Empty and error states: no suggestions survived the check, Claude error, or missing API key.

## Testing
- **Service specs:** stub `Claude::Client` and `Tmdb::Client.request`, matching the existing style. Cover:
  - Context building (audience, exclusions, per-person labeling)
  - The TMDB check (year match, drop when nothing matches)
  - The 12-month hard exclusion
  - Labels and sorting
- **`Claude::Client` spec:** stubs the Anthropic SDK client, so no cassette or API key is needed. If a VCR cassette is ever recorded for it, add `filter_sensitive_data` for the key first. The TMDB key isn't filtered in the existing cassettes either; adding that would change how they match, so it's a separate change.
- **Feature spec:** an admin can reach the page and sees results (stubbed service). A non-admin is redirected with the alert.

## Setup
1. Add `gem 'anthropic'` and run `bundle`.
2. Add `anthropic_api_key` to `config/application.yml` locally and to the Heroku config vars.

## To decide while building
- Exact prompt wording; expect a few rounds of tuning on real lists
- Whether `medium` effort is enough, or `high` gives clearly better picks
