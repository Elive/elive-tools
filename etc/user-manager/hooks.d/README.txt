/etc/user-manager/hooks:
Files from this directory are hooks to run for user creation, where:

- e17-wizard:  hooks to run in the first startup of e17 (new user without e17 conf), useful if you have those needs:
                   * GUI (user interface) dependency
                   * Interactive requirement
                   * All Translations available
                   * X11 access, like GL settings, resolution, etc
               and so on, it is divided in different directories which they are launched in different times, like:
                - after     directory of hooks to run after e17 (wizard) has finished to set up
                - first     before any other wizard pages
                - last      after all wizard pages


# There's also "deliver" for the same things -only- for live, like:
/etc/deliver/hooks/e17-wizard/*
