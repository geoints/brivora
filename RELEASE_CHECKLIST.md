# Brivora release checklist

## Before the first public release

### App
- [ ] flutter pub get
- [ ] dart format --output=none --set-exit-if-changed lib test
- [ ] flutter analyze
- [ ] flutter test
- [ ] flutter build apk --debug
- [ ] Manual smoke test on a real Android phone

### Critical smoke-test path
1. Sign in / sign out.
2. Create a project.
3. Open the project.
4. Create and edit a client.
5. Create a task and verify today's/overdue task appears on Home.
6. Open the estimate and create/edit/delete an item.
7. Generate the PDF.
8. Share the PDF to WhatsApp and Telegram.
9. Add a calculator result to the estimate.
10. Upload, view, edit caption and delete a project photo.
11. Create, edit and delete a note.
12. Update finances.
13. Create, approve/reject and delete a project change.
14. Change language and verify Russian/Kazakh UI.
15. Force-close and reopen the app; verify data persists.

### Security
- [ ] Deploy firestore.rules and storage.rules with Firebase CLI.
- [ ] Verify one user cannot read another user's project.
- [ ] Verify one user cannot create a task/photo/note/client/finance/change under another user's project.
- [ ] Verify ownerId/projectId cannot be changed after creation.
- [ ] Verify arbitrary Firestore collections are denied.
- [ ] Verify Storage uploads are limited to authenticated owners and image MIME types.
- [ ] Verify Storage upload limits: 5 MB for avatars and 10 MB for project photos.
- [ ] Keep payment/subscription collections server-managed until payments are implemented.

### Android release signing
The repository currently uses the debug signing key for the release build type. Do not publish an APK/AAB built with that configuration.
1. Create a private Android upload/release keystore.
2. Keep the keystore and key.properties outside Git.
3. Configure the release signing config in android/app/build.gradle.kts.
4. Build with flutter build appbundle --release.
5. Install the generated AAB/APK on a test device and repeat the smoke test.
6. Back up the keystore securely.

### Firebase deployment
Run from the repository root after confirming the Firebase project:
- firebase deploy --only firestore:rules,storage
- firebase deploy --only functions only when server-side functions are intentionally being deployed.

## Intentionally deferred
- AI features
- In-app payments/subscriptions

These are deliberately excluded from the current release scope.
