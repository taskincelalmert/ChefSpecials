/// Configuration for Google Sign-In.
///
/// [googleServerClientId] is the **Web** OAuth 2.0 client ID of the Firebase
/// project. Google Sign-In needs it as the `serverClientId` so the returned
/// ID token is minted for an audience that Firebase Auth can verify — this is
/// required on Android (otherwise the ID token comes back null).
///
/// Where to find the value (only exists AFTER you enable Google as a sign-in
/// provider in the Firebase console):
///   • android/app/google-services.json → the `oauth_client` entry whose
///     `"client_type": 3` → its `"client_id"`, or
///   • Firebase console → Authentication → Sign-in method → Google →
///     "Web SDK configuration" → Web client ID.
///
/// It looks like: 1036058299740-xxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
const String googleServerClientId =
    '1036058299740-m5ofpdibct7a8jj2ce4h3gc0tlop02r4.apps.googleusercontent.com';
