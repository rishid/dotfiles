# Python 3.12+ — Language-Specific Review Rules

Load alongside `universal.md`. Only Python-specific rules here.

---

## Risk Signals

- `print()` statements in production code
- `# noqa` and `# type: ignore` — verify justification
- `eval()` / `exec()` with any user-controlled input
- `pickle` deserializing untrusted data
- `assert` used for runtime validation — stripped by `-O`

---

## Security

- Flag `eval()` / `exec()` with user-controlled input
- Flag `pickle.loads()` on untrusted data — use `json` or `msgpack`
- Flag `subprocess` with `shell=True` and user input
- Flag `flask.render_template_string()` with user data (SSTI)
- Flag `SECRET_KEY` / `DEBUG = True` committed to source

---

## Async

- Flag `asyncio.get_event_loop().run_until_complete()` inside running loop
- Flag mixing `threading` and `asyncio` without `run_in_executor` bridge
- Flag CPU-bound work in `async def` without `ProcessPoolExecutor`
- Flag `time.sleep()` in async functions — use `await asyncio.sleep()`

---

## Resource Management

- Flag `open()` not used as context manager (`with open(...) as f`)
- Flag `requests.Session` created per-request instead of shared
- Flag DB connections not closed or returned to pool on all paths
- Flag large files read entirely with `.read()` — prefer streaming/chunked

---

## Exception Handling

- Flag bare `except:` — catches `BaseException` including `KeyboardInterrupt`
- Flag `except Exception: pass` — silently swallows errors
- Flag `raise e` instead of `raise` — loses original traceback
- Flag overly broad `except` when `try` covers multiple distinct operations
- **Flag exception type mismatches**: `except Exception as e:` followed by code that accesses attributes specific to a subclass (e.g., `e.detail` which only exists on `HTTPException`). If non-HTTPException is raised, accessing `.detail` crashes with `AttributeError`.
- Flag dispatching caught exceptions to handlers that expect specific exception types without type checking first

---

## Performance

- Flag `+` string concat in loops — use `"".join()`
- Flag `re.compile()` inside a loop — compile once at module level
- Flag `list.append()` in loop where comprehension works
- Flag `in` on large `list` — use `set` for membership tests
- Flag loading entire large files into memory

---

## Code Quality

- Bare `except:` or `except Exception:` swallowing silently
- Mutable default arguments (`def foo(items=[])`) — shared across calls
- `import *` — pollutes namespace, hides dependencies
- Missing type hints on public functions/methods
- **Private API imports**: Importing symbols with leading underscore from third-party libraries (e.g., `from slowapi import _rate_limit_exceeded_handler`) — no stability guarantee, may break on version bumps. Prefer public APIs or copy the implementation.

---

## Idioms (Python 3.12+)

- Prefer `X | None` over `Optional[X]`
- Prefer `TypedDict` or `dataclass` over plain `dict` for structured data
- Prefer `match` statements over long `if/elif` chains
- Prefer `pathlib.Path` over `os.path`
- Prefer f-strings over `.format()` or `%`
- Prefer explicit `if x is None` over falsy checks when `0`/`""` are valid
