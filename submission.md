[`Homework repo branch`](https://github.com/NU-CS-Software-Studio-Spring-26/homework-5-annabel-goldman/tree/feat/todo-priority)
[`AGENTS.md`](AGENTS.md)
[`.cursorignore`](.cursorignore)
[`.cursor/rules/security.mdc`](.cursor/rules/security.mdc)
[`.cursor/rules/rails-conventions.mdc`](.cursor/rules/rails-conventions.mdc)


## Part 3

### Ask mode
Prompt: Where in this codebase are the route definitions currently implemented? Cite the exact files and line numbers. Do not propose changes."

Response: Route definitions live in a single file: config/routes.rb.

Active routes: routes.rb Lines 1-8
Lines	Route definition
1
Opens the routing block (Rails.application.routes.draw do)
2
resources :todos — RESTful todo routes
3
get '/hello', to: 'todos#hello'
8
get "up" => "rails/health#show", as: :rails_health_check

Correct: Yes this was correct and not a hallucination


### Plan mode 
Prompt: I want to change the routes so that we have a new route for week old todo's. Propose a plan as a numbered list of changes, including files to edit, new tests to add, and any migration. Do not write code.

Answer: I'll explore the Todo model, routes, controller, and tests so the plan matches how this app is structured.

No homework spec defines "week old" — I'll default to todos created at least 7 days ago and note the alternative.

Which field should define a "week old" todo?

due_date — todos whose due date was 7+ days ago (overdue/stale items)

Plan: 
Week Old Todos Route Plan
Definition
A week old todo is a todo whose due_date is 7 or more days before today (due_date <= 7.days.ago). Todos with a NULL due_date are excluded.

Architecture
flowchart LR
  Client -->|"GET /todos/week_old"| Routes
  Routes --> TodosController
  TodosController -->|"Todo.week_old"| TodoModel
  TodoModel --> DB[(todos table)]
  TodosController --> HTMLView[week_old.html.erb]
  TodosController --> JSONView[week_old.json.jbuilder]
Numbered changes
1. Add the route
File: config/routes.rb

Change line 2 from bare resources :todos to a block with a collection route.
Add get :week_old inside the collection block.
Resulting path: GET /todos/week_old → todos#week_old
Named route helper: week_old_todos_path / week_old_todos_url
This follows the project convention of RESTful routes on the todos resource (see AGENTS.md), similar in spirit to the existing custom route at line 3 but scoped under the resource.

2. Add query logic on the model
File: app/models/todo.rb

Add a named scope (e.g. week_old) that filters where("due_date <= ?", 7.days.ago) and excludes null due dates.
Keeps the controller thin per project conventions.
No migration needed: db/schema.rb lines 14–19 already include due_date on todos, added by db/migrate/20260519180933_add_due_date_to_todo.rb.

3. Add the controller action
File: app/controllers/todos_controller.rb

Add a week_old action after index (around lines 5–7).
Set @todos = Todo.week_old.
Respond to HTML and JSON formats, matching the pattern used by index and hello (lines 5–7 and 60–64).

4. Add HTML view
File: app/views/todos/week_old.html.erb (new)

Mirror app/views/todos/index.html.erb: page title "Week Old Todos", iterate @todos, render the existing app/views/todos/_todo.html.erb partial.
Reuse shared partials rather than duplicating todo markup (project convention).
Optional small addition to app/views/todos/index.html.erb: a link to week_old_todos_path for discoverability (not required for the route to work).

5. Add JSON view
File: app/views/todos/week_old.json.jbuilder (new)

Mirror app/views/todos/index.json.jbuilder: render @todos via the existing _todo.json.jbuilder partial.
Consider updating app/views/todos/_todo.json.jbuilder to include :due_date in the JSON payload so API consumers can see why a todo appears in this list (minor enhancement, not strictly required for the route).
6. Update test fixtures
File: test/fixtures/todos.yml

Add timestamped due_date values to existing fixtures (or add new fixture entries) so tests have deterministic data:
At least one todo with due_date 8+ days ago (should appear)
At least one todo with due_date within the last week (should not appear)
At least one todo with no due_date (should not appear)
Use relative dates (e.g. based on fixture load time) or explicit past dates consistent with how other tests in the project handle time.

7. Add model tests
File: test/models/todo_test.rb

Currently empty (only a commented placeholder). Add tests for the week_old scope:

Returns todos with due_date 7+ days ago
Excludes todos with recent due_date
Excludes todos with NULL due_date
8. Add controller integration tests
File: test/controllers/todos_controller_test.rb

Add tests following the existing style (lines 8–47):

GET week_old_todos_url returns :success for HTML
GET week_old_todos_url as JSON returns :success
Response body includes week-old fixture todo(s) and excludes recent/null-due-date fixture todo(s)
9. Optional system test
File: test/system/todos_test.rb

Optional (not strictly required): visit week_old_todos_url, assert page heading and that only week-old todos are shown. Lower priority since controller + model tests cover the filtering logic.

EDIT: I removed this section

10. Verify
Run:

bin/rails test
bin/rails routes | grep week_old (confirm route is registered)
Migration summary
None required. The due_date column already exists on todos.

Files touched (summary)
Action	File
Edit	config/routes.rb
Edit	app/models/todo.rb
Edit	app/controllers/todos_controller.rb
New	app/views/todos/week_old.html.erb
New	app/views/todos/week_old.json.jbuilder
Edit	test/fixtures/todos.yml
Edit	test/models/todo_test.rb
Edit	test/controllers/todos_controller_test.rb
Optional edit	app/views/todos/index.html.erb, test/system/todos_test.rb, app/views/todos/_todo.json.jbuilder

### Agent 
Prompt: implement only the first step and then commit please and give me back a markdown link to that commit

Commit: [d8353c3 — Add week_old collection route for todos.](https://github.com/NU-CS-Software-Studio-Spring-26/homework-5-annabel-goldman/commit/d8353c36768285771cb6ede49762c2c8771dd994)

### Bad --> Good Prompt Rewrite 

Good prompt: It looks like right now we don't have a route for the user to go to when they go to "/" we should add a route there. 
Context: @config/routes.rb @app/controllers/todos_controller.rb @test/controllers/todos_controller_test.rb @app/views/todos/index.html.erb @app/javascript/controllers/index.js 

Task: Make the root path "/" load the index page

Expected vs. actual: 
Expected: visiting http://localhost:3000/ shold show the index.html page 
Actual: visting "/" shows the default rails home page 

Constraints: only touch the @config/routes.rb and relevant test files. Don't add any gems. Follow the existing rails convensions. Don't add any additional routes beyond the root in @config/routes.rb

Done when:
The testing passes. Visiting localhost:3000 in the browser shows the same page as localhost:3000/todos. There is no routing error shown 

## Part 4
My own explaination of turbo streams: a small HTML response made of different turbo-stream tags that tell turbo what part of the page to update by element id. There are multiple different knds of turbo actions that tell the code how to update. Append inserts content at the end, prepend inserts content at the start, replace replaces the target element with a new one, update replaces only the inside of a target element but the element itself stays, remove deletes the target element from the DOM, before inserts new content before the target, after intserts new content after the target. There aren't any existing turbo streams set up in this repo. 

Things I verified: The definition of the seven different actions for turbo, however the turbo docs included an eighth, refresh. I also confirmed that as far as I can tell we aren't actually using turbo but it is installed in the repo. 

## Workflow
Prompt: 
Acceptance criteria:
As a user I want to be able to label a todo as high priority so that I can see the todos I consider the most importantant in one easy location.
- Todo gets a high_priority boolean attribute.
- On the todos index, every row has a visible star icon toggle, that shows the current priority state for that todo.
- Clicking that toggle sends a request that flips the priority and returns a Turbo Stream that updates only that row (or only the toggle button). The rest of the page must not re-render.
- Verified in Chrome / Firefox DevTools, Network tab: the response Content-Type is text/vnd.turbo-stream.html , and the request Accept header includes the same MIME type.
- At least one automated test covers the toggle


## Tests

The response.media_type check makes sure that the server returns Turbo Stream format, not a full HTML page. We use the response media type to confirm the response contains an actual turbo-stream element.

command: bin/rails test 
output: Running 9 tests in a single process (parallelization threshold is 50)
Run options: --seed 7323
.........

Finished in 0.445984s, 20.1801 runs/s, 49.3291 assertions/s.
9 runs, 22 assertions, 0 failures, 0 errors, 0 skips


PR: (https://github.com/NU-CS-Software-Studio-Spring-26/homework-5-annabel-goldman/pull/1)
