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

/** Derive type of the result of binary operation */
template TypeOfOp(Tlhs, string op, Trhs)
{
    alias ReturnType!((Tlhs lhs, Trhs rhs) => mixin("lhs"~op~"rhs"))
        TypeOfOp;
}
