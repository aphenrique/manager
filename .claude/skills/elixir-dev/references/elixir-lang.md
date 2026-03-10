# Elixir Language Guidelines

## Listas

Elixir lists **do not support index-based access via the access syntax**:

    # INVALID
    i = 0
    mylist = ["blue", "green"]
    mylist[i]

    # VALID — use Enum.at, pattern matching, or List
    Enum.at(mylist, i)

## Imutabilidade e rebinding

Variables are immutable but can be rebound. For block expressions (`if`, `case`, `cond`), you **must** bind the result externally:

    # INVALID — rebinding inside `if`, result never assigned
    if connected?(socket) do
      socket = assign(socket, :val, val)
    end

    # VALID — rebind result of `if` to a variable
    socket =
      if connected?(socket) do
        assign(socket, :val, val)
      end

## Módulos

- **Never** nest multiple modules in the same file (cyclic deps + compilation errors)

## Structs e Maps

- **Never** use map access syntax (`changeset[:field]`) on structs — they don't implement the Access behaviour by default
- For regular structs, access fields directly: `my_struct.field`
- For Ecto changesets, use `Ecto.Changeset.get_field/2`

## Datas e Horas

- Elixir's stdlib has everything for date/time: `Time`, `Date`, `DateTime`, `Calendar`
- **Never** install extra deps for date/time unless asked (exception: `date_time_parser` for parsing)

## Atoms e Segurança

- Don't use `String.to_atom/1` on user input (memory leak risk)

## Funções predicado

- Predicate function names should NOT start with `is_` and should end in `?`
- Names like `is_thing` are reserved for guards

## OTP

- OTP primitives like `DynamicSupervisor` and `Registry` require names in child spec:

      {DynamicSupervisor, name: MyApp.MyDynamicSup}
      DynamicSupervisor.start_child(MyApp.MyDynamicSup, child_spec)

- Use `Task.async_stream(collection, callback, options)` for concurrent enumeration with back-pressure; pass `timeout: :infinity` in most cases

## Mix

- Read docs before using tasks: `mix help task_name`
- Debug test failures: `mix test test/my_test.exs` or `mix test --failed`
- `mix deps.clean --all` is **almost never needed** — avoid unless there's good reason

## Testes

- **Always use `start_supervised!/1`** to start processes in tests (guarantees cleanup)
- **Avoid** `Process.sleep/1` and `Process.alive?/1`
- Instead of sleeping to wait for a process, use `Process.monitor/1` + assert on DOWN message:

      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, :process, ^pid, :normal}

- Instead of sleeping to synchronize, use `_ = :sys.get_state/1`
