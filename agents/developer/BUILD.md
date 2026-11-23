# AIPA: how to build, run and test (Milestone 1)

The code was written in a Linux session with no Xcode. It has not been compiled yet.
The first build on a Mac is the real check. Please report any error text back to the developer agent.

## What M1 does

- Share an image to AIPA from any app.
- The Share Extension saves it into the App Group folder `Inbox/`.
- A "Got it" tick shows for under a second. The pop-up then closes by itself.
- The AIPA app lists the saved images under "Waiting to be read".
- No network. No permissions prompts. Reading the images arrives in M2.

## What you need

- A Mac with Xcode 26 or later (iOS 26 SDK).
- For a real iPhone: an Apple Developer account and an iPhone on iOS 26.
- For the Simulator: nothing else. No account is needed.

## Steps: run in the Simulator

1. Get the code: clone the repo and switch to branch `claude/dazzling-cray-xsxqwo`.
2. In Finder open `agents/developer/app/` and double-click `AIPA.xcodeproj`.
3. In the Xcode toolbar pick the scheme `AIPA` and any iPhone simulator on iOS 26.
4. Press Cmd+R. The app opens and shows "Nothing waiting".
5. Put a picture in the Simulator: drag any file from `agents/developer/test-images/` onto the Simulator window. It lands in Photos.
6. Open Photos in the Simulator. Open the picture. Tap Share. Tap AIPA.
   - If AIPA is not in the row, scroll to the end, tap More, and switch AIPA on.
7. Expect: a tick with "Got it", then the pop-up closes by itself.
8. Open AIPA. Expect: one row under "Waiting to be read (1)". Swipe left to delete it.

## Steps: run the tests

1. In Xcode press Cmd+U with the `AIPA` scheme and a simulator selected.
2. Expect: 33 test cases, all green.
   - `InboxStoreTests.swift`: saving, rejecting, ordering, removing.
   - `SampleImageTests.swift`: the six sample images are accepted.
3. Optional, from Terminal in `agents/developer/app/`. Swap in a simulator name you have installed:
   `xcodebuild test -project AIPA.xcodeproj -scheme AIPA -destination 'platform=iOS Simulator,name=iPhone 17'`

## Steps: run on a real iPhone

1. In Xcode click the blue `AIPA` project icon at the top of the left sidebar.
2. For each of the targets `AIPA`, `AIPAShare`, `AIPATests`: open "Signing & Capabilities" and choose your Team.
3. If Xcode says the bundle ID is taken, change these three values to your own domain:
   - `AIPA` target bundle ID: `ai.riskmandate.aipa`
   - `AIPAShare` target bundle ID: `ai.riskmandate.aipa.share` (must start with the app's ID)
   - App Group: `group.ai.riskmandate.aipa`
4. If you change the App Group, change it in all three places:
   - `AIPA` target, Signing & Capabilities, App Groups
   - `AIPAShare` target, Signing & Capabilities, App Groups
   - `Shared/AppGroup.swift`, the `identifier` line
5. Plug in the iPhone, select it in the toolbar, press Cmd+R.
6. Take a screenshot. Tap the thumbnail. Tap Share. Tap AIPA. Expect the tick, then check the app.

## Manual checks to tick off

- [ ] Share 1 screenshot: tick shows, pop-up closes by itself, app lists 1 item.
- [ ] Share 3 photos at once from Photos: "3 images saved", app lists 3 more.
- [ ] Share from the screenshot preview (the thumbnail after a screenshot).
- [ ] AIPA does not appear in the share sheet for a web link or plain text.
- [ ] Turn on Airplane Mode and repeat the first check. It must still work.

## If something does not open or build

These parts could not be checked without Xcode. Each has a quick fix.

| Symptom | Fix |
|---|---|
| Xcode says the project cannot be opened | Tell the developer agent the exact message. Workaround: create a new iOS App project named AIPA, add a Share Extension target named AIPAShare and a Unit Testing Bundle named AIPATests, then drag the folders `AIPA`, `AIPAShare`, `Shared`, `AIPATests` in. |
| "Cannot find InboxStore in scope" in `AIPAShare` | Click the `Shared` folder in the sidebar. In the right panel under Target Membership tick both `AIPA` and `AIPAShare`. |
| "Multiple commands produce Info.plist" in `AIPAShare` | Click `AIPAShare/Info.plist`. Untick every Target Membership box. |
| Signing error about App Groups | Do "Steps: run on a real iPhone", items 2 to 4. |
| The share pop-up says shared storage is not set up | The App Group ID does not match in the three places listed above. |

## If the sample images are missing

The test target reads images from `agents/developer/test-images/` through a folder link named `test-images` in the Xcode sidebar.
If the six "Sample images" tests fail with "is not in the test bundle":

1. In the Xcode sidebar delete the `test-images` entry (choose Remove Reference).
2. Drag the folder `agents/developer/test-images` from Finder into the sidebar.
3. In the dialog tick only the target `AIPATests`. Press Finish. Run Cmd+U again.

## Sample images

- Location: `agents/developer/test-images/`. Details: `agents/developer/test-images/README.md`.
- The six files there are drawn placeholders. Please replace them with real screenshots, same file names.

## Regenerating files (optional, any computer with Python 3)

- Project file: `python3 agents/developer/tools/make_xcodeproj.py`
- Placeholder images (needs Pillow): `python3 agents/developer/tools/make_test_images.py`

## API verification status

Checked on 2026-11-23 against developer.apple.com documentation data.

Verified names and availability:
- `FileManager.containerURL(forSecurityApplicationGroupIdentifier:)`
- `NSExtensionContext.inputItems`, `completeRequest(returningItems:completionHandler:)`
- `NSExtensionItem.attachments`
- `NSItemProvider.registeredTypeIdentifiers`, `hasItemConformingToTypeIdentifier(_:)`, `loadDataRepresentation(forTypeIdentifier:completionHandler:)`
- Info.plist keys `NSExtensionPrincipalClass`, `NSExtensionActivationSupportsImageWithMaxCount`
- `UTType.image`, `UTType.preferredFilenameExtension`
- `CGImageSourceCreateWithData`, `CGImageSourceGetType`, `CGImageSourceGetCount`, `CGImageSourceCopyPropertiesAtIndex`, `kCGImagePropertyPixelWidth`
- `Data.WritingOptions.atomic`, `.completeFileProtectionUntilFirstUserAuthentication`
- `URLResourceValues.isExcludedFromBackup`
- `UIHostingController`, `UINotificationFeedbackGenerator`, `UIImage.preparingThumbnail(of:)`, `UIGraphicsImageRenderer`
- `ContentUnavailableView`, `onChange(of:initial:_:)`, `Task.sleep(for:)`
- Swift Testing: `#expect`, `Issue.record`
- `SystemLanguageModel` exists from iOS 26.0. This sets the deployment target. It is not used until M2.

Unverified (no Xcode available):
- That the hand-written `project.pbxproj` opens cleanly in Xcode 26.
- One synchronized folder (`Shared`) belonging to two targets.
- A synchronized folder that points outside the project folder (`../test-images`).
- That the code compiles without warnings. Swift language mode is set to 5.
- Reading back `isExcludedFromBackup` in the Simulator (one test depends on it).
- Share sheet behaviour for every source app. Only the documented item provider calls were used.
