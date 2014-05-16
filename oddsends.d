// Written in the D programming language.

/**
 * This module contains various staff used in multiple prodjects.
 *
 *  Authors:    Maksim Sergeevich Zholudev
 *  Copyright:  Copyright (c) 2014, Maksim Zholudev
 *  License:    $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0)
 */
module oddsends;

import std.traits;
import std.typetuple;

/** Derive type of the result of binary operation */
template TypeOfOp(Tlhs, string op, Trhs)
{
    static if (is(FunctionTypeOf!((Tlhs lhs, Trhs rhs) =>
                                  mixin("lhs"~op~"rhs"))
                  R == return))
        alias R TypeOfOp;
}

/** Test whether binary operation exists for given operand types */
template isExistOp(Tlhs, string op, Trhs)
{
    enum isExistOp = is(TypeOfOp!(Tlhs, op, Trhs));
}

template PointersTo(T...)
{
    static if(T.length == 1)
        alias T[0]* PointersTo;
    else
        alias TypeTuple!(T[0]*, PointersTo!(T[1..$])) PointersTo;
}

template MakeConst(T...)
{
    static if(T.length == 1)
        alias TypeTuple!(const(T[0])) MakeConst;
    else
        alias TypeTuple!(const(T[0]), MakeConst!(T[1..$])) MakeConst;
}

template GetMember(string field, T...)
{
    static if(T.length == 1)
        mixin("alias TypeTuple!(T[0]." ~ field ~ ")[0] GetMember;");
    else
        mixin("alias TypeTuple!(T[0]." ~ field ~
            ", GetMember!(field, T[1..$])) GetMember;");
}

unittest
{
    struct FooA
    {
        alias int Foo;
    }

    struct FooB
    {
        alias double Foo;
    }

    struct FooC
    {
        alias bool Foo;
    }

    static assert(is(GetMember!("Foo", FooA) == int));
    static assert(is(GetMember!("Foo", FooA, FooB, FooC) ==
        TypeTuple!(int, double, bool)));
}

template GetMemberType(string field, T...)
{
    static if(T.length == 1)
        mixin("alias typeof(T[0]." ~ field ~ ") GetMemberType;");
    else
        mixin("alias TypeTuple!(typeof(T[0]." ~ field ~
            "), GetMemberType!(field, T[1..$])) GetMemberType;");
}

unittest
{
    struct FooA
    {
        int foo;
    }

    struct FooB
    {
        double foo;
    }

    struct FooC
    {
        bool foo;
    }

    static assert(is(GetMemberType!("foo", FooA) == int));
    static assert(is(GetMemberType!("foo", FooA, FooB, FooC) ==
        TypeTuple!(int, double, bool)));
}

template staticRange(size_t n)
{
    static if(n == 1)
        enum staticRange = 0;
    else
        enum staticRange = TypeTuple!(staticRange!(n - 1), n - 1);
}

auto passMemberValue(alias func, string field, T...)(T args)
{
    GetMemberType!(field, T) result;
    foreach(i; staticRange!(T.length))
    {
        result[i] = mixin("args[i]." ~ field);
    }
    return func(result);
}

version(unittest)
{
    import std.conv;
    auto f(T...)(T args)
    {
        string result = "";
        foreach(a; args)
            result ~= to!string(a) ~ " ";
        return result;
    }
}

unittest
{
    struct FooA
    {
        int foo;
    }

    struct FooB
    {
        string foo;
    }

    struct FooC
    {
        bool foo;
    }

    auto a = FooA(2);
    auto b = FooB("three");
    auto c = FooC(true);

    assert(passMemberValue!(f, "foo")(a, b, c) == "2 three true ");
}
