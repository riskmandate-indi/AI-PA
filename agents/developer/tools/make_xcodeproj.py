#!/usr/bin/env python3
"""Writes app/AIPA.xcodeproj (project file and shared scheme).

Standard library only. No network. Run from anywhere:
    python3 agents/developer/tools/make_xcodeproj.py

The project uses Xcode "synchronized folders" (project format 77, Xcode 16+).
Source files are picked up from the folders on disk, so this script only
needs to change when a target, folder or build setting changes.
"""
import os
import plistlib
import re
import xml.dom.minidom

APP_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "app")
PROJ_DIR = os.path.join(APP_DIR, "AIPA.xcodeproj")

NAMES = """project mainGroup productsGroup
appProduct shareProduct testsProduct
grpApp grpShare grpShared grpTests grpImages shareException
tApp tShare tTests
appSources appFrameworks appResources appEmbed
shareSources shareFrameworks shareResources
testsSources testsFrameworks testsResources
embedBuildFile
proxyShare depShare proxyApp depApp
projCfgList projDebug projRelease
appCfgList appDebug appRelease
shareCfgList shareDebug shareRelease
testsCfgList testsDebug testsRelease""".split()
# Stable 24 character object IDs.
g = {name: "A1FA%020X" % n for n, name in enumerate(NAMES, start=1)}


def phase(isa, id_, files=""):
    return f"""\t\t{id_} /* {isa} */ = {{
\t\t\tisa = {isa};
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{files}\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
"""


def cfg(id_, name, settings):
    body = "".join(f"\t\t\t\t{k} = {v};\n" for k, v in sorted(settings.items()))
    return f"""\t\t{id_} /* {name} */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
{body}\t\t\t}};
\t\t\tname = {name};
\t\t}};
"""


def cfglist(id_, owner, debug, release):
    return f"""\t\t{id_} /* Build configuration list for {owner} */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug} /* Debug */,
\t\t\t\t{release} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
"""


def syncgroup(id_, path, exception=None, name=None):
    exc = ""
    if exception:
        exc = (
            "\t\t\texceptions = (\n"
            f"\t\t\t\t{exception} /* PBXFileSystemSynchronizedBuildFileExceptionSet */,\n"
            "\t\t\t);\n"
        )
    nm = f'\t\t\tname = "{name}";\n' if name else ""
    quoted = path if path.isalnum() else f'"{path}"'
    return f"""\t\t{id_} /* {name or path} */ = {{
\t\t\tisa = PBXFileSystemSynchronizedRootGroup;
{exc}{nm}\t\t\tpath = {quoted};
\t\t\tsourceTree = "<group>";
\t\t}};
"""


def target(id_, name, cfgl, phases, deps, groups, product, ptype):
    ph = "".join(f"\t\t\t\t{p},\n" for p in phases)
    dp = "".join(f"\t\t\t\t{d} /* PBXTargetDependency */,\n" for d in deps)
    gr = "".join(f"\t\t\t\t{x},\n" for x in groups)
    return f"""\t\t{id_} /* {name} */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {cfgl} /* Build configuration list for PBXNativeTarget "{name}" */;
\t\t\tbuildPhases = (
{ph}\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
{dp}\t\t\t);
\t\t\tfileSystemSynchronizedGroups = (
{gr}\t\t\t);
\t\t\tname = {name};
\t\t\tproductName = {name};
\t\t\tproductReference = {product};
\t\t\tproductType = "{ptype}";
\t\t}};
"""


def paths(*items):
    inner = "".join(f'\t\t\t\t\t"{i}",\n' for i in items)
    return f"(\n{inner}\t\t\t\t)"


# ---- build settings -------------------------------------------------------
common = {
    "ALWAYS_SEARCH_USER_PATHS": "NO",
    "CLANG_ENABLE_MODULES": "YES",
    "CLANG_ENABLE_OBJC_ARC": "YES",
    "CLANG_WARN_BOOL_CONVERSION": "YES",
    "CLANG_WARN_UNREACHABLE_CODE": "YES",
    "COPY_PHASE_STRIP": "NO",
    "ENABLE_STRICT_OBJC_MSGSEND": "YES",
    "GCC_NO_COMMON_BLOCKS": "YES",
    "GCC_WARN_UNINITIALIZED_AUTOS": "YES_AGGRESSIVE",
    "GCC_WARN_UNUSED_VARIABLE": "YES",
    # Foundation Models (Milestone 2) needs iOS 26.
    "IPHONEOS_DEPLOYMENT_TARGET": "26.0",
    "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
    "SDKROOT": "iphoneos",
    "SWIFT_VERSION": "5.0",
}
project_debug = dict(common, **{
    "DEBUG_INFORMATION_FORMAT": "dwarf",
    "ENABLE_TESTABILITY": "YES",
    "GCC_OPTIMIZATION_LEVEL": "0",
    "GCC_PREPROCESSOR_DEFINITIONS": paths("DEBUG=1", "$(inherited)"),
    "ONLY_ACTIVE_ARCH": "YES",
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": '"DEBUG $(inherited)"',
    "SWIFT_OPTIMIZATION_LEVEL": '"-Onone"',
})
project_release = dict(common, **{
    "DEBUG_INFORMATION_FORMAT": '"dwarf-with-dsym"',
    "ENABLE_NS_ASSERTIONS": "NO",
    "SWIFT_COMPILATION_MODE": "wholemodule",
    "VALIDATE_PRODUCT": "YES",
})
target_common = {
    "CODE_SIGN_STYLE": "Automatic",
    "CURRENT_PROJECT_VERSION": "1",
    "DEVELOPMENT_TEAM": '""',
    "GENERATE_INFOPLIST_FILE": "YES",
    "MARKETING_VERSION": "0.1",
    "PRODUCT_NAME": '"$(TARGET_NAME)"',
    "SWIFT_EMIT_LOC_STRINGS": "YES",
    "TARGETED_DEVICE_FAMILY": '"1,2"',
}
app = dict(target_common, **{
    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
    "CODE_SIGN_ENTITLEMENTS": "AIPA/AIPA.entitlements",
    "ENABLE_PREVIEWS": "YES",
    "INFOPLIST_KEY_CFBundleDisplayName": "AIPA",
    "INFOPLIST_KEY_ITSAppUsesNonExemptEncryption": "NO",
    "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
    "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
    "INFOPLIST_KEY_UISupportedInterfaceOrientations": "UIInterfaceOrientationPortrait",
    "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad": (
        '"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown '
        'UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"'
    ),
    "LD_RUNPATH_SEARCH_PATHS": paths("$(inherited)", "@executable_path/Frameworks"),
    "PRODUCT_BUNDLE_IDENTIFIER": "ai.riskmandate.aipa",
})
share = dict(target_common, **{
    "CODE_SIGN_ENTITLEMENTS": "AIPAShare/AIPAShare.entitlements",
    "INFOPLIST_FILE": "AIPAShare/Info.plist",
    "INFOPLIST_KEY_CFBundleDisplayName": "AIPA",
    "LD_RUNPATH_SEARCH_PATHS": paths(
        "$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks"
    ),
    "PRODUCT_BUNDLE_IDENTIFIER": "ai.riskmandate.aipa.share",
    "SKIP_INSTALL": "YES",
})
tests = dict(target_common, **{
    "BUNDLE_LOADER": '"$(TEST_HOST)"',
    "PRODUCT_BUNDLE_IDENTIFIER": "ai.riskmandate.aipa.tests",
    "TEST_HOST": '"$(BUILT_PRODUCTS_DIR)/AIPA.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/AIPA"',
})

PBXPROJ = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 77;
	objects = {{

/* Begin PBXBuildFile section */
		{g['embedBuildFile']} /* AIPAShare.appex in Embed Foundation Extensions */ = {{isa = PBXBuildFile; fileRef = {g['shareProduct']} /* AIPAShare.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */
		{g['proxyShare']} /* PBXContainerItemProxy */ = {{
			isa = PBXContainerItemProxy;
			containerPortal = {g['project']} /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = {g['tShare']};
			remoteInfo = AIPAShare;
		}};
		{g['proxyApp']} /* PBXContainerItemProxy */ = {{
			isa = PBXContainerItemProxy;
			containerPortal = {g['project']} /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = {g['tApp']};
			remoteInfo = AIPA;
		}};
/* End PBXContainerItemProxy section */

/* Begin PBXCopyFilesBuildPhase section */
		{g['appEmbed']} /* Embed Foundation Extensions */ = {{
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 13;
			files = (
				{g['embedBuildFile']} /* AIPAShare.appex in Embed Foundation Extensions */,
			);
			name = "Embed Foundation Extensions";
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXCopyFilesBuildPhase section */

/* Begin PBXFileReference section */
		{g['appProduct']} /* AIPA.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = AIPA.app; sourceTree = BUILT_PRODUCTS_DIR; }};
		{g['shareProduct']} /* AIPAShare.appex */ = {{isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = AIPAShare.appex; sourceTree = BUILT_PRODUCTS_DIR; }};
		{g['testsProduct']} /* AIPATests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = AIPATests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};
/* End PBXFileReference section */

/* Begin PBXFileSystemSynchronizedBuildFileExceptionSet section */
		{g['shareException']} /* Exceptions for "AIPAShare" folder in "AIPAShare" target */ = {{
			isa = PBXFileSystemSynchronizedBuildFileExceptionSet;
			membershipExceptions = (
				Info.plist,
			);
			target = {g['tShare']} /* AIPAShare */;
		}};
/* End PBXFileSystemSynchronizedBuildFileExceptionSet section */

/* Begin PBXFileSystemSynchronizedRootGroup section */
{syncgroup(g['grpApp'], 'AIPA')}{syncgroup(g['grpShare'], 'AIPAShare', g['shareException'])}{syncgroup(g['grpShared'], 'Shared')}{syncgroup(g['grpTests'], 'AIPATests')}{syncgroup(g['grpImages'], '../test-images', name='test-images')}/* End PBXFileSystemSynchronizedRootGroup section */

/* Begin PBXFrameworksBuildPhase section */
{phase('PBXFrameworksBuildPhase', g['appFrameworks'])}{phase('PBXFrameworksBuildPhase', g['shareFrameworks'])}{phase('PBXFrameworksBuildPhase', g['testsFrameworks'])}/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		{g['mainGroup']} = {{
			isa = PBXGroup;
			children = (
				{g['grpApp']} /* AIPA */,
				{g['grpShare']} /* AIPAShare */,
				{g['grpShared']} /* Shared */,
				{g['grpTests']} /* AIPATests */,
				{g['grpImages']} /* test-images */,
				{g['productsGroup']} /* Products */,
			);
			sourceTree = "<group>";
		}};
		{g['productsGroup']} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{g['appProduct']} /* AIPA.app */,
				{g['shareProduct']} /* AIPAShare.appex */,
				{g['testsProduct']} /* AIPATests.xctest */,
			);
			name = Products;
			sourceTree = "<group>";
		}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
{target(g['tApp'], 'AIPA', g['appCfgList'], [g['appSources'], g['appFrameworks'], g['appResources'], g['appEmbed']], [g['depShare']], [g['grpApp'], g['grpShared']], g['appProduct'], 'com.apple.product-type.application')}{target(g['tShare'], 'AIPAShare', g['shareCfgList'], [g['shareSources'], g['shareFrameworks'], g['shareResources']], [], [g['grpShare'], g['grpShared']], g['shareProduct'], 'com.apple.product-type.app-extension')}{target(g['tTests'], 'AIPATests', g['testsCfgList'], [g['testsSources'], g['testsFrameworks'], g['testsResources']], [g['depApp']], [g['grpTests'], g['grpImages']], g['testsProduct'], 'com.apple.product-type.bundle.unit-test')}/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{g['project']} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 2600;
				LastUpgradeCheck = 2600;
				TargetAttributes = {{
					{g['tApp']} = {{
						CreatedOnToolsVersion = 26.0;
					}};
					{g['tShare']} = {{
						CreatedOnToolsVersion = 26.0;
					}};
					{g['tTests']} = {{
						CreatedOnToolsVersion = 26.0;
						TestTargetID = {g['tApp']};
					}};
				}};
			}};
			buildConfigurationList = {g['projCfgList']} /* Build configuration list for PBXProject "AIPA" */;
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {g['mainGroup']};
			minimizedProjectReferenceProxies = 1;
			preferredProjectObjectVersion = 77;
			productRefGroup = {g['productsGroup']} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{g['tApp']} /* AIPA */,
				{g['tShare']} /* AIPAShare */,
				{g['tTests']} /* AIPATests */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
{phase('PBXResourcesBuildPhase', g['appResources'])}{phase('PBXResourcesBuildPhase', g['shareResources'])}{phase('PBXResourcesBuildPhase', g['testsResources'])}/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
{phase('PBXSourcesBuildPhase', g['appSources'])}{phase('PBXSourcesBuildPhase', g['shareSources'])}{phase('PBXSourcesBuildPhase', g['testsSources'])}/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
		{g['depShare']} /* PBXTargetDependency */ = {{
			isa = PBXTargetDependency;
			target = {g['tShare']} /* AIPAShare */;
			targetProxy = {g['proxyShare']} /* PBXContainerItemProxy */;
		}};
		{g['depApp']} /* PBXTargetDependency */ = {{
			isa = PBXTargetDependency;
			target = {g['tApp']} /* AIPA */;
			targetProxy = {g['proxyApp']} /* PBXContainerItemProxy */;
		}};
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
{cfg(g['projDebug'], 'Debug', project_debug)}{cfg(g['projRelease'], 'Release', project_release)}{cfg(g['appDebug'], 'Debug', app)}{cfg(g['appRelease'], 'Release', app)}{cfg(g['shareDebug'], 'Debug', share)}{cfg(g['shareRelease'], 'Release', share)}{cfg(g['testsDebug'], 'Debug', tests)}{cfg(g['testsRelease'], 'Release', tests)}/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
{cfglist(g['projCfgList'], 'PBXProject "AIPA"', g['projDebug'], g['projRelease'])}{cfglist(g['appCfgList'], 'PBXNativeTarget "AIPA"', g['appDebug'], g['appRelease'])}{cfglist(g['shareCfgList'], 'PBXNativeTarget "AIPAShare"', g['shareDebug'], g['shareRelease'])}{cfglist(g['testsCfgList'], 'PBXNativeTarget "AIPATests"', g['testsDebug'], g['testsRelease'])}/* End XCConfigurationList section */
	}};
	rootObject = {g['project']} /* Project object */;
}}
"""


def buildable(target_key, name, product):
    return f"""<BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{g[target_key]}"
               BuildableName = "{product}"
               BlueprintName = "{name}"
               ReferencedContainer = "container:AIPA.xcodeproj">
            </BuildableReference>"""


APP_REF = buildable("tApp", "AIPA", "AIPA.app")
TESTS_REF = buildable("tTests", "AIPATests", "AIPATests.xctest")

SCHEME = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "2600"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            {APP_REF}
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            {TESTS_REF}
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         {APP_REF}
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         {APP_REF}
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""


def check():
    """Structural checks that need no Xcode."""
    text = PBXPROJ
    assert text.count("{") == text.count("}"), "unbalanced braces"
    assert text.count("(") == text.count(")"), "unbalanced parentheses"
    defined = set(re.findall(r"^\t\t(A1FA[0-9A-F]{20})(?: /\*.*?\*/)? = \{", text, re.M))
    used = set(re.findall(r"A1FA[0-9A-F]{20}", text))
    assert used == defined == set(g.values()), f"ID mismatch: {used ^ defined}"
    xml.dom.minidom.parseString(SCHEME)
    for folder, _, files in os.walk(APP_DIR):
        for name in files:
            if name.endswith((".plist", ".entitlements", ".xcprivacy")):
                with open(os.path.join(folder, name), "rb") as handle:
                    plistlib.load(handle)


def main():
    check()
    scheme_dir = os.path.join(PROJ_DIR, "xcshareddata", "xcschemes")
    os.makedirs(scheme_dir, exist_ok=True)
    with open(os.path.join(PROJ_DIR, "project.pbxproj"), "w") as handle:
        handle.write(PBXPROJ)
    with open(os.path.join(scheme_dir, "AIPA.xcscheme"), "w") as handle:
        handle.write(SCHEME)
    print(f"Wrote project with {len(g)} objects. Structural checks passed.")


if __name__ == "__main__":
    main()
