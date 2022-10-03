# CLI Shell template
CLI shell template is a quick start for a you CLI application which allows you to run you CLI commands in sequence aggregating them under 'shell'.
Separate CLI commands can be added without interferring with exising CLI API's through pluggable 'interface'.

# CLI Shell template usage examples
## How to run multiple commands in sequence:
{pre}
./cli.sh -a init,run,stop
{pre}

Argument '-a' gives a possibility to run multiple commands in sequence. If one of those commands fails the remaining ones will be skipped.

## How to run a command and pass some specific configuration
{pre}
./cli -a init,run -r gold
{pre}

As a result running this commands two commands [init;run] will be executed and repository variable (r) where the value is [gold] will be passed to command [init]:
{pre}
./cli.sh -a init,run -r gold
===== Initialization: init =====
MODE: embed
REPOS: gold
init_init ++
===== Execution: init =====
init_exec ++
{pre}
