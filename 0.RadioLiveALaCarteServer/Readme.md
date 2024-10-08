
# Notes sur PiggyBank Server Java



## Build

### Outillage

Les outils disponibles
 - Ceux avec gestions de dépendances/packages
   - Maven
   - Gradle
 - Ceux qui buildent juste (comme make)
   - Ant
 - À la main
   - javac

On choisit **Gradle** parceque j'ai plus de facilité à trouver des informations sur Gradle que sur Maven.

### Commandes

 - Commandes standards
```bash
gradle compileJava
gradle run
gradle build
```

 - Commandes custom qui va sans doute créer
```bash
gradle prtMobileAppPushToTestFlight
```

### Installation

Plus de détails dans [ce document](./docs/Tools-Java-Install.md)





## Initialisation du projet

On a utilisé `gradle init` et on précise un maximum d'options pour éviter les questions interactives

```bash
gradle init \
  --type java-application \
  --dsl groovy \
  --test-framework junit-jupiter \
  --package com.proutechos.sandbox.piggybank.server \
  --project-name PiggyBankServerJava  \
  --no-split-project \
  --java-version 21
```





## Execution de l'application

### Execution de l'application elle-même 

```bash
gradle run
```
Remarque : On dépend de Gradle pour lancer l'application (alors que c'est une outil de Dev et pas de Run)

### Execution des tests

```bash
gradle tests
```

Tips : On peut accéder à un rapport de test en HTML à l'adresse suivante : `file:///Users/eglantine/Dev/0.perso/2.Proutechos/0.PiggyBank/2.PiggyBankServerJava/app/build/reports/tests/test/classes/com.proutechos.sandbox.radiolivealacarte.server.EntryPointTest.html#appHasAGreeting()`

![alt text](<./docs/@images/gradleTestReport.png>)

## Appel de l'API curl

curl -s http://127.0.0.1:8080/makePayment/toAccount/38469403805/withAmount/120/EUR

### Génération du fichier OpenAPI

Cette commande déclenche la génération de la description OpenAPI et place le fichier généré dans /src/main/resources sous  
le nom `piggybank-openapi.json`.

REMARQUE : L'exécution de cette commande suppose, bien sûr, que le projet tourne (en local sur la machine)

```bash
curl -s "http://localhost:8287/api/openapi.json" | jq . > /Users/eglantine/Dev/0.perso/2.Proutechos/0.PiggyBank/2.PiggyBankServerJava/app/src/main/resources/piggybank-openapi.json
```