// Observation parent with an error-only breakpoint symbol in its own image.
// A valid child runs without hitting observation_error; propagate its status.
#include <errno.h>
#include <spawn.h>
#include <stdio.h>
#include <sys/wait.h>
#include <unistd.h>

extern char **environ;

__attribute__((noinline)) void observation_error(int code) {
    fprintf(stderr, "observation-parent error %d\n", code);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        observation_error(64);
        return 64;
    }
    pid_t child;
    int error = posix_spawnp(&child, argv[1], NULL, NULL, &argv[1], environ);
    if (error) {
        observation_error(error);
        return 71;
    }
    int status;
    while (waitpid(child, &status, 0) < 0) {
        if (errno == EINTR) continue;
        observation_error(errno);
        return 71;
    }
    if (WIFEXITED(status)) return WEXITSTATUS(status);
    if (WIFSIGNALED(status)) return 128 + WTERMSIG(status);
    observation_error(71);  // Unexpected wait status, not a child exit code.
    return 71;
}
