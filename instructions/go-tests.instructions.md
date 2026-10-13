---
name: go-tests
description: Go tests: writing or reviewing `_test.go` files.
applyTo: "**/*.go"
paths:
  - "**/*.go"
---

# Testing Conventions

When reviewing, check every rule in this file against each test in the change.

## Rules

- External test package (`package foo_test`) to verify via public API.
- `t.Parallel()` on every test and subtest unless shared mutable state prevents it (e.g., a package-level singleton, shared temp directory, or serial database).
- Table-driven tests (see [template](#table-driven-test-template)) when several cases exercise the same code path with different inputs. A single test function when there is one scenario, or when setup and assertions differ per case.
- Control time with `timing.FixedClock` and explicit advances; wait on async work with channels or `assert.Eventually`/`require.Eventually`. Never `time.Sleep`.
- `require` for fatal preconditions (early return on failure), `assert` for test assertions.

## Logging in Tests

Use `zap.New` writing to stdout (the default). `go test` shows stdout only for failing tests.

```go
log := zap.New(zap.WithLevel(l0g.DebugLevel))
defer log.Close()
```

Assert on state exposed through a method or return value. Use `observable.NewLogger` only when the log line is the behaviour under test (e.g., a specific warning fires); log assertions are brittle.

## Stubs vs Generated Mocks

Use **generated mocks** (mockery) when:
- You need to verify specific call sequences, arguments, or call counts.
- The interface is a key dependency whose interactions define the test's purpose.

Use **hand-rolled stubs** when:
- The interface has many methods but the test only cares about one or two.
- You need a no-op or fixed-value implementation.

Place stubs at the top of the test file, or in `helpers_test.go` when shared.

To generate a mock, add `//mockery:generate: true` above the interface and run `make generate`.

In the test body, set only the mock expectations that are the stimulus or the assertion of the scenario, so a reader sees at a glance which inputs the test controls. Let the fixture absorb unrelated calls through defaults or `.Maybe()`.

## Test Helper Organisation

When test files in a package share setup, put it in `helpers_test.go` (or `mock_helpers_test.go` for mock wiring), so test files hold scenarios only.

- Helpers call `t.Helper()` so failures report the caller's line.
- Name helpers after what they produce (`newTestStore`, `createMeasureDoc`).

## Table-Driven Test Template

Follows the `gotests` layout. Group multiple inputs in the nested `args` struct; inline a single trivial input. Drop `wantErr` and the error branch when the function returns no error.

```go
func TestFoo(t *testing.T) {
	t.Parallel()

	type args struct {
		input Type
		opts  Options
	}
	tests := []struct {
		name    string
		args    args
		want    Type
		wantErr bool
	}{
		{
			name: "descriptive case name",
			args: args{input: ..., opts: ...},
			want: ...,
		},
		{
			name:    "invalid input returns error",
			args:    args{input: ..., opts: ...},
			wantErr: true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			got, err := foo.Foo(tt.args.input, tt.args.opts)

			if tt.wantErr {
				require.Error(t, err)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, tt.want, got)
		})
	}
}
```
