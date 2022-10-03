# CLI Shell template
CLI shell template is a quick start for a you CLI application which allows you to run you CLI commands in sequence aggregating them under 'shell'.
Separate CLI commands can be added without interferring with exising CLI API's through pluggable 'interface'.

# CLI Shell template usage examples
## How to run multiple commands in sequence:
```
./cli.sh -a init,run,stop
```

Argument '-a' gives a possibility to run multiple commands in sequence. If one of those commands fails the remaining ones will be skipped.

## How to run a command and pass some specific configuration
```
./cli -a init,run -r gold
```

As a result running this commands two commands [init;run] will be executed and repository variable (r) where the value is [gold] will be passed to command [init]:
```
./cli.sh -a init,run -r gold
===== Initialization: init =====
MODE: embed
REPOS: gold
init_init ++
===== Execution: init =====
init_exec ++
```
