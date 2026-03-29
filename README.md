# gabash

Handy shortcut functions for Bash and Powershell

## Installation

### Bash
To install all functions:

```
cd ~
git clone git@github.com:gabsoftware/gabash.git
printf '\nsource ~/gabash/gabash_all.sh\n' >> ~/.bashrc
```

To install only one family of functions (e.g. git):
```
cd ~
git clone git@github.com:gabsoftware/gabash.git
printf '\nsource ~/gabash/gabash_git.sh\n' >> ~/.bashrc
```

Then close WSL and reopen it.

### Powershell
For Powershell, add the following line to your profile file:
```. "C:\PathTo\gabash\gabash_all.ps1"```
or
```. "C:\PathTo\gabash\gabash_git.ps1"```
or
```. "C:\PathTo\gabash\gabash_docker.ps1"```
or
```. "C:\PathTo\gabash\gabash_unx.ps1"```

The profile file path can be found by typing:
```$profile```

If no profile file exists, you can create one with:
```New-Item -Path $profile -ItemType File -Force```

Then you can edit the profile file with:
```notepad $profile```

## Update

```
cd ~/gabash && git pull
```

Then close WSL and reopen it.


## Command list

### Gabash
- `gabash --help` : displays a description of gabash and the commands of loaded modules
- `gabash --help <command>` : displays detailed help for a command (e.g. `gabash --help gpull`)
- `gabash --version` : displays the gabash version (or `GABASH_VERSION` if defined)
- autocompletion : `gabash <TAB>` and `gabash --help <TAB>` suggest available options/commands based on loaded modules

### Nginx
- `ngr` : Restarts the nginx service
- `ngt` : Checks the nginx configuration (nginx -t)
- `ngs` : Shows the nginx service status

### Git
- `cb` : Cleans up local branches deleted from the server
- `ga` : git add
- `gb` : git branch
- `gc` : git switch (branches) or git restore (files/paths)
- `gd` : git diff
- `gf` : git fetch --all
- `gr` : git reset
- `gs` : git status
- `gcom` : git commit
- `glog [number]` : git log -n [number] (optional; default 1)
- `gpull` : git pull
- `gpush` : git push
- `gmerge` : git merge
- `gclean --confirm` : git reset --hard HEAD && git clean -fd
- `gx` : git update-index --chmod=+x

### Docker
- `de <image_name> <tag>` : checks if the image exists in your personal registry
- `dt <image_name> <tag>` : docker tag (checks if tag already exists)
- `dtl <image_name> <tag>` : tags the image with the given tag then with `latest`
- `dp <image_name> <tag>` : docker push (checks if tag already exists in registry)
- `dpl <image_name> <tag>` : pushes the given tag then `latest`
- `dpush <image_name> <tag>` : alias for `dp`
- `dpull <image_name> [tag]` : docker pull (default tag: `latest`)
- `dl` : lists images in your personal registry
- `dl <image_name>` : lists tags for the image
- `dcb <service_name> [service_name2 ...]` : docker compose build
- `dcbnc <service_name> [service_name2 ...]` : docker compose build with --no-cache
- `dcu <service_name> [service_name2 ...]` : docker compose up -d
- `dcund <service_name> [service_name2 ...]` : docker compose up -d --no-deps
- `dstop <service_name> [service_name2 ...]` : docker compose stop (docker stop if outside a compose project)
- `ddown <service_name> [service_name2 ...]` : docker compose down
- `dkill <service_name> [service_name2 ...]` : docker compose kill (docker kill if outside a compose project)
- `dps [args ...]` : docker compose ps (docker ps if outside a compose project)
- `dlogs <container_name_or_id>` : docker logs --follow
- `dexec <container_name_or_id> [args ...]` : docker exec
- `dx <container_name_or_id> [args ...]` : alias for `dexec`

### Unix-like (Powershell)
- `which [-as] <command> [command ...]` : shows the path of a command like the unix equivalent (`-a`: all matches, `-s`: silent)
- `grep [-ivnrlcwxFEs] <pattern> [file ...]` : searches for a pattern (common options: `-i`, `-v`, `-n`, `-r`, `-l`, `-c`, `-w`, `-x`, `-F`, `-E`, `-s`)
- `head [-n N] [file ...]` : shows the first lines (10 by default)
- `tail [-n N] [-f] [file ...]` : shows the last lines and follows new additions with `-f`
