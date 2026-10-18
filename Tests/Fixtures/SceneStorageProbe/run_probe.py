"""Build and launch the actual SwiftStorage product; preserve command and assertion receipts."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import time
import uuid

parser = argparse.ArgumentParser()
parser.add_argument("platform", choices=["macos", "ios"])
parser.add_argument("--evidence", type=Path, required=True)
parser.add_argument("--device")
parser.add_argument("--suite", choices=["peer-regression", "full", "restoration"], default="peer-regression")
args = parser.parse_args()
fixture = Path(__file__).resolve().parent
root = fixture.parents[2]
out = args.evidence.resolve()
out.mkdir(parents=True, exist_ok=False)
commands = []


def call(argv, name):
    result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    (out / (name + ".log")).write_text(result.stdout)
    commands.append({"argv": argv, "exit": result.returncode, "log": name + ".log"})
    (out / "commands.json").write_text(json.dumps(commands, indent=2))
    if result.returncode:
        raise SystemExit(f"{name} failed: see {out / (name + '.log')}")
    return result.stdout.strip()


sources = list((root / "Sources").rglob("*.swift")) + list(fixture.rglob("*.swift"))
(out / "sources.json").write_text(json.dumps({str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
                                             for p in sources}, indent=2))
call(["swift", "--version"], "swift-version")
call(["sw_vers"], "os-version")
build = ["swift", "build", "--package-path", str(fixture), "--scratch-path", str(out / "build"),
         "--product", "SceneStorageProbe"]
if args.platform == "ios":
    if not args.device:
        parser.error("ios requires an explicit --device UDID")
    sdk = call(["xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"], "sdk")
    build += ["--sdk", sdk, "--triple", "arm64-apple-ios17.0-simulator"]
call(build, "build")
binary = out / "build" / "debug" / "SceneStorageProbe"
app = out / "SceneStorageProbe.app"
bundle = "dev.swifthelpers.sceneprobe.r" + uuid.uuid4().hex
contents = app / "Contents" if args.platform == "macos" else app
executable = contents / "MacOS" if args.platform == "macos" else app
executable.mkdir(parents=True)
shutil.copy2(binary, executable / "SceneStorageProbe")
info = {"CFBundleIdentifier": bundle, "CFBundleExecutable": "SceneStorageProbe", "CFBundleName": "SceneStorageProbe",
        "CFBundlePackageType": "APPL", "CFBundleVersion": "1", "CFBundleShortVersionString": "1.0",
        "NSHighResolutionCapable": True}
if args.platform == "ios":
    info.update({"MinimumOSVersion": "17.0", "UIDeviceFamily": [1, 2], "UILaunchScreen": {},
                 "UIApplicationSceneManifest": {"UIApplicationSupportsMultipleScenes": True}})
with (contents / "Info.plist").open("wb") as f:
    plistlib.dump(info, f)
call(["codesign", "--force", "--sign", "-", str(app)], "sign")
def launch_and_observe(phase):
    suffix = "-" + phase if phase else ""
    launch_args = ["--suite", args.suite] + (["--phase", phase] if phase else [])
    if args.platform == "macos":
        runtime = out / ("runtime" + suffix + ".jsonl")
        call(["open", "-n", "--stderr", str(out / ("stderr" + suffix + ".log")), str(app),
              "--args", "--output", str(runtime), *launch_args], "launch" + suffix)
    else:
        runtime = container / "Documents" / ("runtime" + suffix + ".jsonl")
        call(["xcrun", "simctl", "launch", args.device, bundle, "--output", str(runtime), *launch_args], "launch" + suffix)
    deadline = time.monotonic() + 30
    while time.monotonic() < deadline:
        if runtime.exists():
            records = [json.loads(line) for line in runtime.read_text().splitlines() if line]
            if any(r["event"] == "complete" for r in records):
                break
        time.sleep(0.1)
    else:
        raise SystemExit("app completion timed out; no assertion verdict")
    if args.platform == "ios":
        shutil.copy2(runtime, out / runtime.name)
        call(["xcrun", "simctl", "terminate", args.device, bundle], "terminate" + suffix)
    return records


if args.platform == "ios":
    call(["xcrun", "simctl", "install", args.device, str(app)], "install")
    container = Path(call(["xcrun", "simctl", "get_app_container", args.device, bundle, "data"], "container"))
records = launch_and_observe("seed" if args.suite == "restoration" else "")
if args.suite == "restoration":
    time.sleep(0.5)
    records += launch_and_observe("read")
checks = [r for r in records if r["event"] == "check"]
verdict = {"checks": len(checks), "failed": [r["name"] for r in checks if not r["pass"]],
           "nativeFailures": [r["name"] for r in checks if r["nativeControl"] and not r["pass"]], "bundle": bundle}
(out / "verification.json").write_text(json.dumps(verdict, indent=2))
print(json.dumps(verdict))
raise SystemExit(1 if verdict["failed"] else 0)
