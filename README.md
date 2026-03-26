# gabash

Fonctions pratiques pour bash

## Installation

### Bash
Pour avoir toutes les fonctions:

```
cd ~
git clone git@github.com:gabsoftware/gabash.git
printf '\nsource ~/gabash/gabash_all.sh\n' >> ~/.bashrc
```

Pour n'installer qu'une famille de fonctions (par exemple git)
```
cd ~
git clone git@github.com:gabsoftware/gabash.git
printf '\nsource ~/gabash/gabash_git.sh\n' >> ~/.bashrc
```

Puis fermer le WSL et le relancer.

### Powershell
Pour Powershell if faut ajouter la ligne suivante dans votre fichier de profil:
```. "C:\CheminVers\gabash\gabash_all.ps1"```
ou
```. "C:\CheminVers\gabash\gabash_git.ps1"```
ou
```. "C:\CheminVers\gabash\gabash_docker.ps1"```
ou
```. "C:\CheminVers\gabash\gabash_unx.ps1"```

Le fichier de profil peut être trouvé en tapant:
```$profile```

Si aucun fichier de profil n'existe, vous pouvez en créer un avec :
```New-Item -Path $profile -ItemType File -Force```

Puis vous pouvez modifier le fichier de profil avec :
```notepad $profile```

## Mise à jour

```
cd ~/gabash && git pull
```

Puis fermer le WSL et le relancer.


## Liste des commandes

### Gabash
- `gabash --help` : affiche une description de gabash et les commandes des modules charges
- `gabash --help <command>` : affiche l'aide detaillee d'une commande (ex: `gabash --help gpull`)
- `gabash --version` : affiche la version de gabash (ou `GABASH_VERSION` si defini)
- autocompletion : `gabash <TAB>` et `gabash --help <TAB>` suggerent les options/commandes disponibles selon les modules charges

### Nginx
- `ngr` : Redémarre le service nginx
- `ngt` : Vérifie la configuration du service nginx (nginx -t)

### Git
- `cb` : Nettoyage des branches locales supprimées du serveur
- `ga` : git add
- `gb` : git branch
- `gc` : git switch (branches) ou git restore (fichiers/chemins)
- `gd` : git diff
- `gf` : git fetch --all
- `gr` : git reset
- `gs` : git status
- `gcom` : git commit
- `glog [number]` : git log -n [number] (optionnel ; par défaut 1)
- `gpull` : git pull
- `gpush` : git push
- `gmerge` : git merge
- `gclean --confirm` : git reset --hard HEAD && git clean -fd
- `gx` : git update-index --chmod=+x

### Docker
- `de <image_name> <tag>` : vérifie si l'image existe dans le votre registry perso
- `dt <image_name> <tag>` : docker tag (avec vérification si le tag existe déjà)
- `dtl <image_name> <tag>` : tag l'image avec le tag donné puis avec `latest`
- `dp <image_name> <tag>` : docker push (avec vérification si le tag existe déjà dans le registry)
- `dpl <image_name> <tag>` : push le tag donné puis `latest`
- `dpush <image_name> <tag>` : alias de `dp`
- `dpull <image_name> [tag]` : docker pull (tag par défaut: `latest`)
- `dl` : liste les images du votre registry perso
- `dl <image_name>` : liste les tags de l'image
- `dcb <service_name> [service_name2 ...]` : docker compose build
- `dcbnc <service_name> [service_name2 ...]` : docker compose build avec --no-cache
- `dcu <service_name> [service_name2 ...]` : docker compose up -d
- `dcund <service_name> [service_name2 ...]` : docker compose up -d --no-deps
- `dstop <service_name> [service_name2 ...]` : docker compose stop (docker stop si en dehors d'un projet avec compose)
- `ddown <service_name> [service_name2 ...]` : docker compose down
- `dkill <service_name> [service_name2 ...]` : docker compose kill (docker kill si en dehors d'un projet avec compose)
- `dps [args ...]` : docker compose ps (docker ps si en dehors d'un projet avec compose)
- `dlogs <container_name_or_id>` : docker logs --follow
- `dexec <container_name_or_id> [args ...]` : docker exec
- `dx <container_name_or_id> [args ...]` : alias de `dexec`

### Unix-like (Powershell)
- `which [-as] <command> [command ...]` : affiche le chemin d'une commande comme l'equivalent unix (`-a`: toutes les correspondances, `-s`: silencieux)
- `grep [-ivnrlcwxFEs] <pattern> [file ...]` : recherche un motif (options courantes: `-i`, `-v`, `-n`, `-r`, `-l`, `-c`, `-w`, `-x`, `-F`, `-E`, `-s`)
- `head [-n N] [file ...]` : affiche les premieres lignes (10 par defaut)
- `tail [-n N] [-f] [file ...]` : affiche les dernieres lignes et suit les ajouts avec `-f`
