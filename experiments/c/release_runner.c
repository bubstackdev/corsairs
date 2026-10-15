// Controlled native observation parent. Keep debugger instrumentation outside
// CPython's subprocess machinery; the child runs the unchanged frozen checker.
#include <errno.h>
#include <spawn.h>
#include <stdio.h>
#include <sys/wait.h>
#include <unistd.h>
extern char **environ;
int main(int argc, char **argv) {
    if (argc < 2) return 64;
    pid_t child;
    int error = posix_spawnp(&child, argv[1], NULL, NULL, &argv[1], environ);
    if (error) { errno = error; perror("posix_spawnp"); return 71; }
    int status;
    while (waitpid(child, &status, 0) < 0) {
        if (errno == EINTR) continue;
        perror("waitpid"); return 71;
    }
    if (WIFEXITED(status)) return WEXITSTATUS(status);
    if (WIFSIGNALED(status)) return 128 + WTERMSIG(status);
    return 71;
}
