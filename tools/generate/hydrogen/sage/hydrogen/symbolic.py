def simplify_identity(expression):
    return (
        expression
        .simplify_full()
        .simplify_trig()
        .simplify_full()
    )
