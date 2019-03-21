# Hooks

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ssfrr.github.io/Hooks.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ssfrr.github.io/Hooks.jl/dev)
[![Build Status](https://travis-ci.com/ssfrr/Hooks.jl.svg?branch=master)](https://travis-ci.com/ssfrr/Hooks.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/ssfrr/Hooks.jl?svg=true)](https://ci.appveyor.com/project/ssfrr/Hooks-jl)
[![Codecov](https://codecov.io/gh/ssfrr/Hooks.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ssfrr/Hooks.jl)

Hooks.jl is a simple and lightweight package allowing handler code to be triggered on certain events (hooks), regardless of the order in which the handlers and hook were defined. This is particularly useful for inter-package interoperability to eliminate cases where package load order matters.

To notify a hook, which will call any registered handlers, use `Base.notify`. This will also add the hook to the registry, so any future handlers will be called immediately on registration.

To add a handler for a hook, use the `handle` function exported by Hooks.jl. It takes a function and a hook name. You can also use Julia's `do` notation to define the handler code.

```julia
julia> handle(hook"some-event") do
    println("first handler for some-event called")
end

julia> handle(hook"some-event") do
    println("second handler for some-event called")
end

julia> notify(hook"some-event")
first handler for some-event called
second handler for some-event called
```

## Hook Arguments

Any arguments passed to `notify` will be passed along to any registered handlers.

```julia
julia> handle(hook"some-event") do x, y
    println("handler for some-event called with args $x and $y")
end

julia> notify(hook"some-event", 100, 200)
handler for some-event called with args 100 and 200
```

## Order independence

One of the main motivations for Hooks.jl is to reduce dependency on ordering for events and their handlers. If a handle is `notify`d, any future handlers will be executed as soon as they are registered.

```julia
julia> handle(hook"some-event") do
    println("first handler for some-event called")
end

julia> notify(hook"some-event")
first handler for some-event called

julia> handle(hook"some-event") do
    println("second handler for some-event called")
end
second handler for some-event called
```

## Deregistering

`handle` returns the handler function itself. Passing this to `unhandle` will deregister that handler, so it won't be called the next time the hook is notified.

```julia
julia> handler = handle(hook"some-event") do
    println("handler for some-event called")
end

julia> notify(hook"some-event")
handler for some-event called

julia> unhandle(handler)

julia> notify(hook"some-event")
```

## Duplicate Registrations

If the same function is registered for the same hook multiple times, it will only be registered once.

## Clearing Registrations

The `reset` function will remove all registered handlers from a given hook. It will also clear the run state for that hook, so handlers won't be run until the next `notify` call.

## Hook Naming Guidelines

All hooks share a global namespace, so it is important to name carefully to reduce the chance of a conflict. It is also useful to maintain a consistent naming convention so hooks are easier to remember. Because hooks and handlers can be defined in any order, there's no error if a hook and handler have subtly-different names (e.g. different capitalization), and keeping the names consistent also reduces this kind of error.

* prefix the hook with the name of the package that notifies the hook
* hook names should be all lower-case
* separate words with hyphens
