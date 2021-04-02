# minecli

Minecraft CLI with RCON support and Journalctl logs

This is a Minecraft RCON command-line client written in Crystal. In the interactive mode, logs from journalctl can be streamed to the console, which is especially useful for commands that only returns output in the logs. This client also serves as an alternative to the built-in console, but without having to keep a TTY.

## Installation

The pre-built binaries can be found at the [releases](https://github.com/chamburr/minecli/releases) page.

If there are no binaries available for your platform, please build them yourself. The instructions for building are below.

## Building from Source

Please install the [Crystal](https://crystal-lang.org/install) Language.

Then, running the following commands.

```sh
shards install --ignore-crystal-version
shards build --release
```

The binary will be generated at `bin/minecli`.

## Usage

For this to work, RCON must be enabled on your Minecraft server. You also need to use systemd to manage the process, so that logs can be fetched from journalctl. An example systemd service configuration can be found [here](examples/minecraft.service).

```
Minecraft CLI

USAGE:
    minecli [OPTIONS] [COMMAND]

OPTIONS:
    --host <host>                    Server host (default: 127.0.0.1)
    --port <port>                    Server port (default: 25575)
    --password <password>            Server password (default: minecraft)
    --unit <unit>                    Journalctl unit (default: minecraft)
    --lines <lines>                  Lines of logs to display
    --no-logs                        Disable journalctl logs
    -h, --help                       Print the help message and exit
    -v, --version                    Print version information and exit
```

Notes:
- The options can also be specified with `MINECLI_OPTS` environmental variable.
- Without any command specified, minecli will start in interactive mode.

## License

This project is licensed under [MIT License](LICENSE).
