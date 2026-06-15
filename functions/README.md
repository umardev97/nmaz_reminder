Cloud Functions for Prayer & Daily Family Tracking App

Deployment:

1. Install Firebase CLI and login:

```bash
npm install -g firebase-tools
firebase login
```

2. From this `functions/` directory, install dependencies and deploy:

```bash
cd functions
npm install
firebase deploy --only functions
```

Environment:
- Set `DEFAULT_LAT` and `DEFAULT_LON` in the Functions environment if you want to override Lahore.

Examples:

```bash
firebase functions:config:set app.default_lat="31.5204" app.default_lon="74.3587"
```

Azan sound:
- Add an `azan.mp3` sound file to the following locations before using custom sounds:
	- `assets/sounds/azan.mp3` (Flutter asset)
	- `android/app/src/main/res/raw/azan.mp3` (Android raw resource)
	- `ios/Runner/Resources/azan.mp3` (iOS app bundle)

Replace the placeholder files included in the repo with a real Azan mp3.
