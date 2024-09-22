
# Installation d'outils Java


## SDKMAN

On choisit d'installer tous les outils du monde Java via SDKMAN plutôt que Brew (car SDKMAN est pratique pour jongler entre plusieurs versions d'outils Java)

 - SDKMAN
Installation dans un répertoire spécifique
```bash
export SDKMAN_DIR="/Applications/DevTools/Java/sdkman" && curl -s "https://get.sdkman.io" | bash   
```
**REMARQUE**: Ne pas oublier de modifier le `.zshrc` pour qu'il pointe bien au bon endroit
```bash
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Applications/DevTools/Java/sdkman"
[[ -s "/Applications/DevTools/Java/sdkman/bin/sdkman-init.sh" ]] && source "/Applications/DevTools/Java/sdkman/bin/sdkman-init.sh"
export PATH="/opt/homebrew/opt/tcl-tk/bin:$PATH"
```

## JVM (Java Virtual Machine)

```bash
sdk install java 21.0.3-zulu
```

## Gradle

```bash
sdk install gradle 8.6
```
