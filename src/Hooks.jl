module Hooks

export @hook_str, handle, unhandle

struct HookName{S} end

mutable struct Hook
    handlers::Set{Any}
    hasrun::Bool
    args::Tuple
end

@inline Hook(args...) = Hook(Set{Any}(args), false, ())

"""
    hook"some-event"

String macro to represent the name of a hook.
"""
macro hook_str(name)
    :(HookName{Symbol($name)}())
end

hooks = Dict{Symbol, Hook}()

function Base.notify(::HookName{S}, args...) where S
    hook = get(hooks, S, nothing)
    if hook === nothing
        hook = Hook()
        hooks[S] = hook
    end

    for h in hook.handlers
        h(args...)
    end

    hook.hasrun = true
    hook.args = args

    nothing
end

function handle(handler, ::HookName{S}) where S
    if S in keys(hooks)
        hook = hooks[S]
        push!(hook.handlers, handler)
        if hook.hasrun
            handler(hook.args...)
        end
    else
        hooks[S] = Hook(handler)
    end

    handler
end

function unhandle(handler, ::HookName{S}) where S
    hook = get(hooks, S, nothing)
    if hook === nothing
        throw(ErrorException("Hook $S not found"))
    end
    if handler in hook.handlers
        delete!(hook.handlers, handler)
    else
        throw(ErrorException("Hook $S has no handler $handler"))
    end

    nothing
end

function Base.reset(::HookName{S}) where S
    hook = get(hooks, S, nothing)
    if hook === nothing
        throw(ErrorException("Hook $S not found"))
    end
    hook.handlers = Set()
    hook.hasrun = false
    hook.args = ()

    nothing
end

end # module
