using Hooks
using Test
@testset "Hooks.jl" begin
    @testset "Basic Notification" begin
        run = false
        handle(hook"test") do
            run = true
        end

        notify(hook"test")
        @test run
        reset(hook"test")
    end

    @testset "Multiple handlers" begin
        run1 = false
        run2 = false
        handle(hook"test") do
            run1 = true
        end

        handle(hook"test") do
            run2 = true
        end

        notify(hook"test")
        @test run1
        @test run2
        reset(hook"test")
    end

    @testset "Hook Resetting" begin
        run1 = false
        run2 = false
        handle(hook"test") do
            run1 = true
        end

        handle(hook"test") do
            run2 = true
        end
        reset(hook"test")

        notify(hook"test")
        @test !run1
        @test !run2
        reset(hook"test")
    end

    @testset "Reverse order registration" begin
        run1 = false
        run2 = false
        notify(hook"foobar")

        handle(hook"foobar") do
            run1 = true
        end

        handle(hook"foobar") do
            run2 = true
        end

        @test run1
        @test run2
        reset(hook"foobar")
    end

    @testset "Deregistration" begin
        run1 = false
        run2 = false
        h1 = handle(hook"test") do
            run1 = true
        end

        h2 = handle(hook"test") do
            run2 = true
        end

        unhandle(h1, hook"test")

        notify(hook"test")
        @test !run1
        @test run2
        reset(hook"test")
    end

    @testset "Multiple Hooks" begin
        run1 = false
        run2 = false
        h1 = handle(hook"test1") do
            run1 = true
        end

        h2 = handle(hook"test2") do
            run2 = true
        end

        notify(hook"test1")
        notify(hook"test2")
        @test run1
        @test run2
        reset(hook"test1")
        reset(hook"test2")
    end

    @testset "Errors on resettinging nonexistent hook" begin
        @test_throws ErrorException reset(hook"does-not-exist")
    end

    @testset "Errors on unhandling nonexistent hook" begin
        @test_throws ErrorException unhandle(()->100, hook"does-not-exist")
    end

    @testset "Errors on unhandling nonexistent handler" begin
        handle(()->42, hook"test")
        @test_throws ErrorException unhandle(()->100, hook"test")
        reset(hook"test")
    end

    @testset "Duplicate Handlers are merged" begin
        called = 0
        function duphandle()
            called += 1
        end

        handle(duphandle, hook"test")
        handle(duphandle, hook"test")
        notify(hook"test")
        @test called == 1
        reset(hook"test")
    end

    @testset "Handlers can take arguments" begin
        args1 = nothing
        args2 = nothing
        handle(hook"test") do x, y
            args1 = (x,y)
        end
        notify(hook"test", 100, 200)

        # also test the handlers get called when registered afterwards
        handle(hook"test") do x, y
            args2 = (x,y)
        end

        @test args1 == (100, 200)
        @test args2 == (100, 200)
        reset(hook"test")
    end
end
