# CLI Shell template
CLI shell template is a quick start for a you CLI application which allows you to run you CLI commands in sequence aggregating them under 'shell'.
Separate CLI commands can be added without interferring with exising CLI API's through pluggable 'interface'.

# CLI Shell template usage examples
## How to run multiple commands in sequence:
```
./cli.sh -a init,run,stop
```

Argument `-a` gives a possibility to run multiple commands in sequence. If one of those commands fails the remaining ones will be skipped.

## How to run a command and pass some specific configuration
```
./cli -a init,run -r gold
```

As a result running this commands two commands `init;run` will be executed and repository variable (r) where the value is `gold` will be passed to command `init`:
```
./cli.sh -a init,run -r gold
===== Initialization: init =====
MODE: embed
REPOS: gold
init_init ++
===== Execution: init =====
init_exec ++
```

## CLI API contract
You can define your own CLI contract which will be used to execute CLI contract operations upon CLI command execution.
Default CLI contract `init->exec->clean` is already provided as a template:
```
for app in ${APPS[@]}; do
    start=$SECONDS
    func_exists $app before && { echo "===== Initialization: $app ====="; eval $app"_init"; }
    func_exists $app exec && { echo "===== Execution: $app ====="; eval $app"_exec"; }
    func_exists $app after && { echo "===== Cleanup: $app ====="; eval $app"_clean" $3; }
    duration=$(( SECONDS - start ))
    echo "Execution time: $duration seconds"
done
```
As a result each CLI command for example `init`, `run` will be tight to shell scripts under `scripts` folder where coresponding CLI commands cli bash files: `init.sh`, `run.sh` resides. Each CLI command contract functions will be executed in the order which which is defined in CLI command contract executor (`init.sh`):
```
init_init() {
    echo "MODE:" $MODE
    echo "REPOS:" $REPOS
    echo "init_init ++"
}

init_exec() {
    echo "init_exec ++"
}

init_clean() {
    echo "init_clean ++"
}
```

### What it takes to add a new CLI command
1. You need to add shell script with you command name to `scripts` folder. For example `kafka.sh` (you can take existing one as template)
2. Add a new command variable under `# COMMAND LIST` (see file cli.sh, line #11)
3. Update the usage section (cli.sh, line #39)
4. Update func_exist with you newly introcuded command variable name (cli.sh, line #66)

As a result you can issue your newly added command:
```
./cli.sh -a kafka
```
