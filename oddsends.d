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
import std.typecons;

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

template PointersToTypes(T...)
{
    static if(T.length == 1)
        alias T[0]* PointersToTypes;
    else
        alias Tuple!(T[0]*, PointersToTypes!(T[1..$])) PointersToTypes;
}
