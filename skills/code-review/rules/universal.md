# Universal Rules — All Languages

These rules apply regardless of language. Load alongside the relevant language-specific rules file.

---

## Security

- Flag string interpolation/concatenation used to build SQL, shell, LDAP, or template queries — require parameterized queries or safe APIs
- Flag hardcoded credentials, API keys, tokens, secrets, or connection strings — require env vars or secrets manager
- Flag user-controlled input passed to filesystem, process execution, or URL redirect APIs without validation
- Flag overly broad CORS or CSP policies
- Flag deserialization of untrusted data without validation

---

## Async / Concurrency

- Flag shared mutable state accessed from multiple threads/coroutines/tasks without synchronization
- Flag fire-and-forget async operations with no error handling path
- Flag missing timeouts on network or I/O calls
- Flag unbounded queues or thread/worker pools with no backpressure

---

## Resource Management

- Flag resources (file, socket, DB connection, HTTP connection) acquired without guaranteed release on all paths (including errors)
- Flag connection/pool resources not returned on exception paths
- Flag unbounded collections that grow without eviction — memory leak risk
- Flag resources held open longer than the operation requires

---

## Exception / Error Handling

- Flag empty catch/except blocks — swallowed errors hide bugs
- Flag catching broadest exception type where a specific type is appropriate
- Flag exceptions used for normal control flow (prefer return values)
- Flag error context lost when re-throwing — wrap with original cause

---

## Performance

- Flag N+1 query patterns — loading collection then querying per item
- Flag unbounded queries/API calls with no pagination or limit
- Flag synchronous I/O on a thread/event loop serving concurrent requests
- Flag large objects serialized/deserialized repeatedly that could be cached
- Flag string concatenation in tight loops — use builder or join
