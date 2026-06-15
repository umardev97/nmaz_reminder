const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require('node-fetch');

admin.initializeApp();
const db = admin.firestore();

const DEFAULT_LAT = process.env.DEFAULT_LAT || '31.5204';
const DEFAULT_LON = process.env.DEFAULT_LON || '74.3587';

async function fetchPrayerTimes(lat, lon) {
  const now = new Date();
  const timestamp = Math.floor(now.getTime() / 1000);
  const url = `https://api.aladhan.com/v1/timings/${timestamp}?latitude=${lat}&longitude=${lon}&method=2`;
  const res = await fetch(url);
  if (!res.ok) throw new Error('Prayer API error');
  const body = await res.json();
  return body.data.timings; // object with Fajr, Dhuhr, Asr, Maghrib, Isha
}

function parseTimeToDate(today, timeStr) {
  // timeStr like '05:12' or '05:12 (EET)'
  const parts = timeStr.split(' ')[0].split(':');
  const hour = parseInt(parts[0], 10);
  const minute = parseInt(parts[1], 10);
  return new Date(today.getFullYear(), today.getMonth(), today.getDate(), hour, minute);
}

exports.checkMissedPrayers = functions.pubsub
  .schedule('every 15 minutes')
  .onRun(async (context) => {
    const now = new Date();
    const dateStr = now.toISOString().slice(0, 10);
    const usersSnap = await db.collection('users').get();
    const promises = [];
    usersSnap.forEach((userDoc) => {
      promises.push((async () => {
        const uid = userDoc.id;
        const userData = userDoc.data();
        const lat = (userData.location && userData.location.lat) || DEFAULT_LAT;
        const lon = (userData.location && userData.location.lon) || DEFAULT_LON;

        // fetch prayer times
        let timings;
        try {
          timings = await fetchPrayerTimes(lat, lon);
        } catch (e) {
          console.error('Failed to fetch prayer times for', uid, e);
          return;
        }

        // fetch today's prayer doc
        const prayerDocRef = db.collection('prayers').doc(uid).collection('dates').doc(dateStr);
        const prayerDoc = await prayerDocRef.get();
        const prayerData = prayerDoc.exists ? prayerDoc.data() : {};

        // check each prayer if missed by 30 minutes
        const checkPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
        const tokensSnap = await db.collection('users').doc(uid).collection('fcm').get();
        const tokens = tokensSnap.docs.map(d => d.id);
        if (!tokens.length) return;

        for (const prayer of checkPrayers) {
          const key = prayer.toLowerCase();
          const done = prayerData && prayerData[key];
          if (done) continue;
          const timingStr = timings[prayer];
          if (!timingStr) continue;
          const scheduled = parseTimeToDate(now, timingStr);
          const diffMinutes = (now - scheduled) / 1000 / 60;
          // check followup doc to respect cancellations
          const followDocRef = db.collection('users').doc(uid).collection('followups').doc(`${dateStr}_${key}`);
          const followSnap = await followDocRef.get();
          if (!followSnap.exists) continue;
          const followData = followSnap.data() || {};
          if (followData.cancelled) continue;

          if (diffMinutes > 30) {
            // send missed-prayer alert
            const message = {
              tokens: tokens,
              notification: {
                title: 'Missed Prayer Alert',
                body: `It looks like you missed ${prayer} today. Please try to pray and mark it.`,
              },
              android: { notification: { sound: 'azan' } },
              apns: { payload: { aps: { sound: 'azan.mp3' } } },
              data: { type: 'missed_prayer', prayer: prayer },
            };
            try {
              const resp = await admin.messaging().sendMulticast(message);
              console.log('Sent missed alert to', uid, prayer, resp.successCount);
              // mark followup as sent to avoid duplicate alerts
              await followDocRef.set({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
            } catch (e) {
              console.error('Send failed', e);
            }
          }
        }
      })());
    });
    await Promise.all(promises);
    return null;
  });

// Callable function to send a test notification to a user's tokens
exports.sendTestNotification = functions.https.onCall(async (data, context) => {
  const uid = data.uid;
  if (!uid) throw new functions.https.HttpsError('invalid-argument', 'uid required');
  const tokensSnap = await db.collection('users').doc(uid).collection('fcm').get();
  const tokens = tokensSnap.docs.map(d => d.id);
  if (!tokens.length) return { success: false, message: 'no tokens' };
  const message = {
    tokens: tokens,
    notification: { title: 'Test', body: 'This is a test notification' },
    android: { notification: { sound: 'azan' } },
    apns: { payload: { aps: { sound: 'azan.mp3' } } },
  };
  await admin.messaging().sendMulticast(message);
  return { success: true };
});
