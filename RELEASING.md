# Releasing to Google Play

How to sign the app, build the bundle and send a release to Play Console. The
scripts that upload the store listing and the release notes are explained in
[fastlane/README.md](fastlane/README.md).

Play only accepts a release signed with your own upload key. Without one,
a release build still finishes, but its APK or bundle is unsigned: a phone
will not install it and Play rejects it. Debug builds, which CI makes, are
signed by Android's own debug key and need nothing.

## Make the upload key (once)

Keep the key outside the repository, for example in `~/.android/cephalopod/`.
From the root of the repository, this makes the key with a random password,
asks nothing, and writes `app/android/keystore.properties`, which git ignores:

```sh
dir=$HOME/.android/cephalopod
jks=$dir/cephalopod-release.jks
mkdir -p "$dir"
[ -e "$jks" ] && { echo "Already exists: $jks"; false; } || {
  pw=$(openssl rand -base64 24 | tr -d '/+=' | cut -c1-24)
  keytool -genkeypair -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 \
    -keystore "$jks" -alias cephalopod-release \
    -dname "CN=Cephalopod, O=Cephalopod" \
    -storepass "$pw" -keypass "$pw"
  printf 'storeFile=%s\nstorePassword=%s\nkeyAlias=cephalopod-release\nkeyPassword=%s\n' \
    "$jks" "$pw" "$pw" > app/android/keystore.properties
  chmod 600 app/android/keystore.properties "$jks"
}
```

The properties file looks like this (the store and key passwords are the same):

```properties
storeFile=/home/you/.android/cephalopod/cephalopod-release.jks
storePassword=the random password
keyAlias=cephalopod-release
keyPassword=the random password
```

**Back up the `.jks` file and the password** (it is in that file) in a password
manager, and somewhere else too. With Play App Signing, Google holds the key
that signs what people install, so a lost upload key can be reset by Google's
support. Still, it takes days, so keep the backup.

When you upload the first bundle, Play Console asks how the app is signed. Keep
Google's own key, the default: your `.jks` is then only the upload key. The
choice cannot be changed after the first upload. Bringing your own app signing
key needs Google's `pepk.jar` tool, and you would have to keep that key secret
for ever.

## Build the bundle

```sh
cd app
flutter build appbundle
```

The signed bundle is `build/app/outputs/bundle/release/app-release.aab`. The
version comes from `pubspec.yaml`: in `1.0.0+1`, `1.0.0` is what people see
and `1` is the build number. Play wants a higher build number for every
upload, so raise it each time.

To check that the bundle is signed with your upload key, and not unsigned:

```sh
keytool -J-Duser.language=en -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

It prints the owner and the fingerprints of the key. If it says the file is not
signed, the bundle is unsigned: check `keystore.properties`. (`-J-Duser.language=en`
only makes `keytool` answer in English, whatever the language of the system.)

## Each release, in order

1. In `app/pubspec.yaml`, raise the number after the `+` (the build number), and
   the version too if people should see a new one.
2. Add the release notes for that number in every language, as
   `fastlane/metadata/android/<locale>/changelogs/<number>.txt`.
3. Build the bundle and upload it to a track in Play Console, by hand.
4. If the listing changed, run `tool/upload_store_listing.sh`.
5. Run `tool/upload_release_notes.sh`. It must come after step 3: Play keeps the
   notes inside a release, so the version has to be on the track already.

Both scripts, and the key they need, are explained in
[fastlane/README.md](fastlane/README.md). Add `--track` and `--version-code` when
the release is not on the internal track, or is not the one in `pubspec.yaml`.

## Privacy policy

The policy is [docs/privacy-policy.md](docs/privacy-policy.md). Play Console asks for
a web address, and this is the one to give it:
`https://github.com/siempredelao/Cephalopod-Flutter/blob/main/docs/privacy-policy.md`.
If the app ever collects or sends data, change the policy first, and the Data
safety form in Play Console with it.
