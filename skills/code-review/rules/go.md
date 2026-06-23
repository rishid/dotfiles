# Go — Language-Specific Review Rules

Load alongside `universal.md`. Only Go-specific rules here.

---

## Risk Signals

- `fmt.Println` / `log.Println` debug statements in production code
- `//nolint` comments — verify justification
- `unsafe` package imports — require explicit sign-off
- Hardcoded credentials or tokens in source

---

## Security

- Flag `database/sql` queries built with `fmt.Sprintf` — require `?` / `$N` placeholders
- Flag `os/exec` with user-controlled arguments without sanitization
- Flag `text/template` used for HTML output instead of `html/template`
- Flag `InsecureSkipVerify: true` in TLS config

---

## Concurrency

- Flag goroutines with no clear lifetime or cancellation — always pass `context.Context`
- Flag goroutines writing to channel with no receiver and no `select` default — leak
- Flag `time.Sleep()` as synchronization mechanism in goroutines
- Flag `sync.WaitGroup.Add()` called inside the goroutine it tracks — race condition
- Flag `sync.Mutex` copied by value — must be pointer or embedded

---

## Resource Management

- Flag `http.Response.Body` not closed — even on error paths (`defer resp.Body.Close()`)
- Flag `os.File` not closed — use `defer f.Close()` immediately after open
- Flag `rows.Close()` missing after `sql.Query()` — leaks DB connection
- Flag `context.WithCancel`/`WithTimeout` cancel function not called — context leak

---

## Error Handling

- Flag errors assigned to `_` without comment explaining why safe to ignore
- Flag errors not wrapped with `fmt.Errorf("...: %w", err)` — loses context
- Flag `errors.New`/`fmt.Errorf` strings starting with capital or ending in punctuation
- Flag `panic()` for expected runtime errors — reserve for programming errors
- Flag `recover()` silently swallowing panics without logging

---

## Performance

- Flag `fmt.Sprintf` for simple string concat — use `strings.Builder` or `+`
- Flag `append()` in tight loop without pre-allocating capacity — use `make([]T, 0, n)`
- Flag `json.Marshal`/`Unmarshal` in hot paths — consider `json.Encoder`/streaming
- Flag goroutines per-request without worker pool for CPU-bound tasks

---

## Idioms

- All returned errors must be checked — never assign to `_` without comment
- Wrap errors with `fmt.Errorf("...: %w", err)` for context
- Use `errors.Is` / `errors.As` — never string comparison
- Every goroutine must have an owner responsible for its lifetime
- Pass `context.Context` as first argument to functions doing I/O
- Prefer `errgroup` over ad-hoc channel coordination
- Prefer generics over `interface{}` for containers (Go 1.18+)
