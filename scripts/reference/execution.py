"""Execution requirements shared by reference collection and golden freezing."""


def select_os_framework(environment):
    """Override inherited framework selectors before importing native bindings."""
    environment["USE_OS_COREAI"] = "1"
    environment.pop("USE_LOCAL_COREAI", None)


def execution_error(observation):
    """Return a failure reason unless backing and child exit match its status.

    A numerical mismatch is a completed invocation with exit 1, never a suite
    success. Only the freezer's separate digest review can accept that mismatch.
    """
    if observation.get("os_backed") is not True:
        return "Reference must use OS Core AI (os_backed must be true)"
    status = observation.get("status")
    expected_exits = {"passed": 0, "expected_error": 0, "mismatch": 1,
                      "error": 1, "unexpected_success": 1}
    if not isinstance(status, str) or status not in expected_exits:
        return f"Unknown reference execution status: {status!r}"
    returncode = observation.get("returncode")
    if type(returncode) is not int or returncode != expected_exits[status]:
        return f"Reference status {status!r} requires exit {expected_exits[status]}, got {returncode!r}"
    return None
