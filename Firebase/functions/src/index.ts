import * as functions from 'firebase-functions';

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

import admin = require('firebase-admin');
admin.initializeApp();

exports.alertCreated = functions.firestore.document('alerts/{alertId}')
.onCreate((snap, _) => {
    // Get an object representing the document
    // e.g. {'name': 'Marie', 'age': 66}
    const newValue = snap.data();

    if (!newValue) { return 1; }

    const alertMessage = newValue.message;
    if (!(typeof alertMessage === 'string')) { return 1; }

    const alertLevel = newValue.level;
    if (!(typeof alertLevel === 'string')) { return 1; }

    const alertName = newValue.alertName;
    if (!(typeof alertName === 'string')) { return 1; }

    const topicsUpdatePromises: Promise<FirebaseFirestore.WriteResult>[] = [];
    const mainTopic = sanitize(alertName);
    const sender    = sanitize(newValue.sender);
    const location  = sanitize(newValue.location);

    // Generate all topic names related to the alert
    const topics = [mainTopic];                                     // The alert name itself
    if (typeof sender === 'string' && sender.length !== 0) {
        topics.push(sender);                                        // The sender
        topics.push(mainTopic + '-' + sender);                      // The couple 'alert_name-sender'
    }
    if (typeof location === 'string' && location.length !== 0) {
        topics.push(location);                                      // The location
        topics.push(mainTopic + '-' + location);                    // The couple 'alert_name-location'
    }

    // Get the `FieldValue` object
    const FieldValue = admin.firestore.FieldValue;
    
    for (const topic of topics) {
        // Atomically increment the alert counter in 'topics' and store the new level.
        // https://firebase.google.com/docs/firestore/manage-data/add-data?authuser=1#increment_a_numeric_value
        topicsUpdatePromises.push(
            admin.firestore().collection('topics').doc(topic).set({
                alertCount: FieldValue.increment(1),
                level: alertLevel,
                message: alertMessage
            }, {merge: true})
        );
    }
    const topicsUpdatePromise = Promise.all(topicsUpdatePromises);

    // Store the topics array in the alert document.
    const documentUpdatePromise = snap.ref.update({ topics: topics });

    return Promise.all([topicsUpdatePromise, documentUpdatePromise]);
});

exports.alertDeleted = functions.firestore.document('alerts/{alertId}')
.onDelete((snap, _) => {
    const newValue = snap.data();
    if (!newValue) { return 1; }

    const topics = newValue.topics;
    if (!topics) { return 1; }

    // Get the `FieldValue` object
    const FieldValue = admin.firestore.FieldValue;

    const topicsUpdatePromises: Promise<FirebaseFirestore.WriteResult>[] = [];
    for (const topic of topics) {
        // Atomically increment the alert counter in 'topics' and store the new level.
        // https://firebase.google.com/docs/firestore/manage-data/add-data?authuser=1#increment_a_numeric_value
        topicsUpdatePromises.push(
            admin.firestore().collection('topics').doc(topic).set({
                alertCount: FieldValue.increment(-1)
            }, {merge: true})
        );
    }

    return topicsUpdatePromises;
});

exports.topicUpdated = functions.firestore.document('topics/{topicId}')
.onUpdate((change, context) => {
    const oldValue = change.before.data();
    const newValue = change.after.data();

    if (!(oldValue) || !(newValue)) { return 1; }

    const oldLevel = oldValue.level;
    if (!(typeof oldLevel === 'string')) { return 1; }
    const newLevel = newValue.level;
    if (!(typeof newLevel === 'string')) { return 1; }

    if (newLevel === oldLevel) { return 1; }

    const alertMessage = newValue.message;
    if (!(typeof alertMessage === 'string')) { return 1; }

    const documentUpdatePromise = change.after.ref.set({
        previousLevel: oldLevel
    }, {merge: true});

    const topic = context.params.topicId;

    // Send a message to devices subscribed to the topics.
    const notificationPromise = admin.messaging().send({
        notification: {
            title: newLevel,
            body: alertMessage,
            //badge: 1,
        },
        data: {
            level: newLevel,
            message: alertMessage
        },
        topic: topic
    })
    .then((response) => {
        console.log('Successfully sent message: ', response);
    })
    .catch((error) => {
        console.error('Error sending message: ', error);
    });

    return Promise.all([documentUpdatePromise, notificationPromise]);
});

exports.createAlert = functions.https.onRequest((req, res) => {
    // Forbidding PUT requests.
    if (req.method !== 'POST') {
        return res.status(403).send('Forbidden!');
    }

    const db = admin.firestore();
    
    // Checking attributes.
    // Throwing HttpsErrors so that the client gets the error details.
    const alertName = req.body.id;
    if (!(typeof alertName === 'string') || alertName.length === 0) {
        // If alertName is not a string with characters
        throw new functions.https.HttpsError('invalid-argument', 'Les donnees doivent contenir un attribut "id" indiquant le nom de l\'alerte.');
    }
    const topic = sanitize(alertName);
    if (topic.length === 0) {
        // If valid topic has no character
        throw new functions.https.HttpsError('invalid-argument', 'Le nom de l\'alerte sans les caracteres interdits ne contient plus de caracteres.');
    }
    const message = req.body.message;
    if (!(typeof message === 'string') || message.length === 0) {
        // If message is not a string with characters
        throw new functions.https.HttpsError('invalid-argument', 'Les donnees doivent contenir un attribut "message" expliquant l\'alerte à l\'utilisateur.');
    }
    const level = req.body.level;
    if (!(typeof level === 'string' && (['INFO', 'WARNING', 'CRITICAL', 'OK']).includes(level))) {
        // If level is not a string in ['INFO', 'WARNING', 'CRITICAL', 'OK']
        throw new functions.https.HttpsError('invalid-argument', 'Les donnees doivent contenir un attribut "level" indiquant le niveau d\'alerte ("INFO", "WARNING", "CRITICAL" ou "OK").');
    }
    const previousLevel = req.body.previousLevel;
    if (!((typeof previousLevel === 'string' && (['INFO', 'WARNING', 'CRITICAL', 'OK']).includes(previousLevel)) || typeof previousLevel === 'undefined')) {
        // If previousLevel exists but is not a string in ['INFO', 'WARNING', 'CRITICAL', 'OK']
        throw new functions.https.HttpsError('invalid-argument', 'Les donnees doivent contenir un attribut "previousLevel" indiquant le niveau d\'alerte précédent ("INFO", "WARNING", "CRITICAL" ou "OK").');
    }

    const requestData = req.body.data
    if (!(typeof requestData === 'object')) {
        throw new functions.https.HttpsError('invalid-argument', 'Les donnees doivent contenir un objet "data".');
    }
    // We only have one series, so there's no doubt it's the first
    const series = requestData.series[0]; // FIXME: Find the index of the series 'mesures'
    if (!(typeof series === 'object') || series.length === 0) {
        throw new functions.https.HttpsError('invalid-argument', 'L\'objet "data" des donnees doit contenir un tableau "series".');
    }
    const tags = series.tags;
    if (!(typeof tags === 'object')) {
        throw new functions.https.HttpsError('invalid-argument', 'Le tableau "series" de l\'objet "data" doit contenir un dictionnaire "tags" contenant les tags et leur valeur.');
    }
    let sender = tags.sender;
    if (!(typeof sender === 'string') || sender.length === 0) {
        throw new functions.https.HttpsError('invalid-argument', 'Le dictionnaire "data.series[0].tags" doit contenir un attribut "sender" contenant le nom du capteur ayant envoye les donnees.');
    }
    sender = sanitize(sender);
    if (sender.length === 0) {
        // If valid sender has no character
        throw new functions.https.HttpsError('invalid-argument', 'Le nom du capteur ayant envoye les donnees sans les caracteres interdits ne contient plus de caracteres.');
    }
    let location = tags.location;
    if (!(typeof location === 'string') || location.length === 0) {
        throw new functions.https.HttpsError('invalid-argument', 'Le dictionnaire "data.series[0].tags" doit contenir un attribut "location" contenant la zone geographique associee au capteur.');
    }
    location = sanitize(location);
    if (sender.length === 0) {
        // If valid location has no character
        throw new functions.https.HttpsError('invalid-argument', 'La zone geographique associee au capteur sans les caracteres interdits ne contient plus de caracteres.');
    }
    const columns = series.columns;
    if (!(typeof columns === 'object')) {
        throw new functions.https.HttpsError('invalid-argument', 'Le tableau "series" de l\'objet "data" doit contenir un tableau "columns" contenant les noms des colonnes.');
    }
    // We only have one series, so there's no doubt it's the first
    const values = series.values[0]; // FIXME: Find the index of the series 'mesures'
    if (!(typeof values === 'object')) {
        throw new functions.https.HttpsError('invalid-argument', 'Le tableau "series" de l\'objet "data" doit contenir un tableau "values" contenant les valeurs de l\'alerte.');
    }

    const timestamp = values[columns.indexOf('time')];
    if (!(typeof timestamp === 'string') || timestamp.length === 0) {
        // FIXME: Check for RFC3339 UTC conformance
        throw new functions.https.HttpsError('invalid-argument', 'Invalid type for "time"');
    }
    const windSpeed = values[columns.indexOf('wind_speed')];
    if (!(typeof windSpeed === 'number' || typeof windSpeed === 'undefined')) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid type for "wind_speed"');
    }
    const windDirection = values[columns.indexOf('wind_direction')];
    if (!(typeof windDirection === 'number' || typeof windDirection === 'undefined')) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid type for "wind_direction"');
    }
    const temperature = values[columns.indexOf('temperature')];
    if (!(typeof temperature === 'number' || typeof temperature === 'undefined')) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid type for "temperature"');
    }
    const battery = values[columns.indexOf('battery')];
    if (!(typeof battery === 'number' || typeof battery === 'undefined')) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid type for "battery"');
    }
    const roll = values[columns.indexOf('roll')];
    if (!(typeof roll === 'number' || typeof roll === 'undefined')) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid type for "roll"');
    }
    const pitch = values[columns.indexOf('pitch')];
    if (!(typeof pitch === 'number' || typeof pitch === 'undefined')) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid type for "pitch"');
    }
    const compass = values[columns.indexOf('compass')];
    if (!(typeof compass === 'number' || typeof compass === 'undefined')) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid type for "compass"');
    }
    const latitude = values[columns.indexOf('latitude')];
    if (!(typeof latitude === 'number' || typeof latitude === 'undefined')) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid type for "latitude"');
    }
    const longitude = values[columns.indexOf('longitude')];
    if (!(typeof longitude === 'number' || typeof longitude === 'undefined')) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid type for "longitude"');
    }

    // const alertDataObject: any = {};
    // for (let i = 0; i < columns.length; i++) {
    //     alertDataObject[columns[i] as string] = values[i];
    // }
    // const alertData = alertDataObject as { [key: string]: any };

    const data = {
        timestamp:      timestamp,
        alertName:      alertName,
        message:        message,
        level:          level,
        previousLevel:  (typeof previousLevel   === 'undefined') ? null : previousLevel,
        topic:          topic,
        sender:         sender,
        location:       location,
        // values:         alertData,
        windSpeed:      (typeof windSpeed      === 'undefined') ? null : windSpeed,
        windDirection:  (typeof windDirection  === 'undefined') ? null : windDirection,
        temperature:    (typeof temperature     === 'undefined') ? null : temperature,
        battery:        (typeof battery         === 'undefined') ? null : battery,
        roll:           (typeof roll            === 'undefined') ? null : roll,
        pitch:          (typeof pitch           === 'undefined') ? null : pitch,
        compass:        (typeof compass         === 'undefined') ? null : compass,
        latitude:       (typeof latitude        === 'undefined') ? null : latitude,
        longitude:      (typeof longitude       === 'undefined') ? null : longitude
    };
    
    // Add a new document in collection "alerts"
    return db.collection('alerts').add(data).then(result => {
        console.log("Nouvelle alerte '", topic, "' disponible à ", result.path);
        res.status(200).send("Nouvelle alerte créée avec succès.");
    }).catch(error => {
        console.log("Erreur: ", error.message);
    });
});

function sanitize(str: string): string {
    return str
        .normalize('NFD').replace(/[\u0300-\u036f]/g, "")   // Remove accents (https://stackoverflow.com/a/37511463/10967642)
        .replace(/\s/g, "_")                                // Replace whitespaces by underscores
        .replace(/-/g, "_")                                 // Replace dashes by underscores to keep dashes as separators
        .replace(/[^a-zA-Z0-9_.~%-]/g, "");                 // Remove remaining prohibited characters
}

// This is just a development function, to format data that is not formatted the right way
// TODO: Delete this function
exports.formatData = functions.https.onRequest((req, res) => {
    // Forbidding PUT requests.
    if (req.method !== 'POST') {
        return res.status(403).send('Forbidden!');
    }

    const db = admin.firestore();

    const topicNamesUpdatePromise = db.collection('alerts').listDocuments()
    .then(documents => {
        console.log('Listed ', documents.length, ' document(s) to update their topicName.');
        documents.forEach(documentRef => {
            return documentRef.get().then(document => {
                const documentData = document.data();
                if (!documentData) { return; }

                const topicName = documentData.topic;
                if (!(typeof topicName === 'string') || topicName.length === 0) {
                    console.error('Could not read topic in document ', document.id);
                    return;
                }

                const topic = sanitize(topicName);
                return document.ref.update({
                    topicName: topicName,
                    topic: topic,
                });
            });
        });
        return;
    });

    return Promise.all([topicNamesUpdatePromise])
    .then(_ => {
        res.status(200).send('200 OK');
    }).catch(_ => {
        res.status(500).send('500 Internal Server Error');
    });
});
