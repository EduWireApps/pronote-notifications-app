# 🔔 Notifications pour Pronote

Notifications pour Pronote est une application mobile qui étend les fonctionnalités de l'application [Pronote](https:/https://play.google.com/store/apps/details?id=com.IndexEducation.Pronote) en envoyant des notifications lors de l'ajout d'un devoir ou d'une note.

## Fonctionnalités

* Envoi de notifications lorsqu'un devoir est ajouté sur Pronote
* Envoi de notifications lorsqu'une note est ajoutée sur Pronote
* Support de tous les collèges et lycées utilisant Pronote

### Prévues

* Envoi de notifications lorsqu'un cours des deux prochaines semaines est annulé
* Envoi de notifications lorsque la salle d'un cours des deux prochaines semaines est modifiée
* Ajout d'un bouton `Supprimer mes données`

## Fonctionnement

Pronote ne disposant pas d'API, le seul moyen de détecter des ajouts de devoirs/notes/... est de se connecter à un interval de temps régulier et de comparer le résultat avec le précédent, ce qui est effectué par [l'API de l'application](https://github.com/pronote-notifications/pronote-notifications-api). Pour cela, l'API doit disposer au préalable des identifiants des utilisateurs et les mots de passes sont donc stockés par l'API pour se connecter automatiquement. Un bouton pour supprimer les données est prévu mais n'est pas encore disponible. Si vous souhaitez que vos données soient supprimés, vous pouvez m'envoyer un mail (`androz2091@gmail.com`).

Le code est entièrement open source :

* [repository de l'application mobile](https://github.com/pronote-notifications/pronote-notifications-app)
* [repository de l'API de l'application](https://github.com/pronote-notifications/pronote-notifications-api)

### Made with

<code><img height="20" src="https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/flutter/flutter.png"></code> **Flutter** (front-end)  
<code><img height="20" src="https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/nodejs/nodejs.png"></code> **Node.js** (back-end)  
<code><img height="20" src="https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/postgresql/postgresql.png"></code> **PostgreSQL** (base de données)  
<code><img height="20" src="https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/firebase/firebase.png"></code> **Firebase** (notifications)  