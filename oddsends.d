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

template isAll(string pred, T...)
{
    static assert(T.length > 0);
    alias T[0] a;
    enum bool isFirst = mixin(pred);
    static if(T.length == 1)
        enum bool isAll = isFirst;
    else
        enum bool isAll = isFirst && isAll!(pred, T[1..$]);
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

    import std.traits;
    static assert(isAll!("hasMember!(a, \"foo\")", FooA, FooB, FooC));
    static assert(!isAll!("hasMember!(a, \"foo\")", FooA, FooB, FooC, int));
}
