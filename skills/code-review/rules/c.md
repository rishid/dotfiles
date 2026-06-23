# C — Language-Specific Review Rules

Load alongside `universal.md`. Only C-specific rules here.

---

## Risk Signals

- `printf` / `fprintf(stderr, ...)` debug statements in production code
- `// TODO` / `// FIXME` near memory management — high risk
- Disabled compiler warnings (`#pragma GCC diagnostic ignore`, `-w` in Makefile)
- Banned functions: `gets`, `strcpy`, `strcat`, `sprintf`, `scanf` without width limits

---

## Security

- Flag `gets()` — always buffer overflow; use `fgets()`
- Flag `strcpy()` / `strcat()` — use `strncpy`/`strncat` with size, or `strlcpy`/`strlcat`
- Flag `sprintf()` — use `snprintf()` with buffer size
- Flag `scanf("%s", buf)` without width specifier — unbounded read
- Flag `strlen()` result used as signed integer — truncation on 64-bit
- Flag user data as format string (`printf(user_input)`) — format string attack
- Flag integer arithmetic as array index without bounds check
- Flag signed integer overflow — undefined behavior in C

---

## Concurrency

- Flag shared global/static variables accessed from threads without mutex or `_Atomic`
- Flag `pthread_mutex_t` / `sem_t` not initialized before use
- Flag signal handlers calling non-async-signal-safe functions (`malloc`, `printf`)
- Flag `volatile` as substitute for synchronization — insufficient
- Flag inconsistent lock acquisition order across call sites — deadlock risk

---

## Resource Management

- Flag every `malloc`/`calloc`/`realloc` — verify matching `free` on all exit paths
- Flag `fopen` without matching `fclose` on all paths including errors
- Flag `dup`/`socket`/`open` FDs not closed on all paths
- Flag VLAs of unbounded size — stack overflow risk
- Flag `realloc` return assigned to source pointer — leaks on failure

---

## Error Handling

- Flag ignored return values from `malloc`, `fopen`, `read`, `write`, `close`
- Flag `errno` checked after wrong function or not immediately after correct one
- Flag `perror`/`strerror` as sole error handling in library code — propagate to callers
- Flag `assert()` for runtime errors — disabled by `NDEBUG` in production

---

## Performance

- Flag `strlen()` called repeatedly on same string in loop — cache result
- Flag large structs passed by value — pass by pointer
- Flag `memcpy`/`memset` on overlapping regions — use `memmove`
- Flag repeated heap allocations in tight loop — consider pool or stack allocation
- Flag `volatile` on non-hardware/non-signal variables — prevents optimization

---

## Idioms

- Every pointer must have clear owner responsible for freeing — document ownership
- Set pointers to `NULL` after `free` — catch use-after-free
- Prefer `calloc` over `malloc` + `memset` for zero-initialized allocations
- Use `const` on pointer params the function does not modify
- Always check `NULL` from allocation functions
- Use `size_t` for sizes and counts — never `int`
- Compile with `-Wall -Wextra -Werror`
- Use `stdint.h` types for fixed-width requirements
