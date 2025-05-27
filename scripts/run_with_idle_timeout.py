import argparse
import signal
import subprocess
import sys
import threading
import time

def main():
    p = argparse.ArgumentParser(
        description="Run a command, kill if idle, retry until timeout")
    p.add_argument(
        "--idle",
        type=float,
        default=30,
        help="Seconds of no-output before we kill the process")
    p.add_argument(
        "--timeout",
        type=float,
        default=600,
        help="Total wall-clock seconds after which we give up")
    p.add_argument(
        "--retries",
        type=int,
        default=3,
        help="Number of retries before giving up (default: 3). Only considered for test fails."
    )
    p.add_argument(
        "cmd",
        nargs=argparse.REMAINDER,
        help="Command to run (e.g. xcodebuild …)")
    args = p.parse_args()
    if not args.cmd:
        print("⚠️  No command given to run", file=sys.stderr)
        sys.exit(2)

    # Flatten the command list (it comes in as ['--', 'xcodebuild', ...])
    # strip a leading "--" if present
    cmd = args.cmd
    if cmd[0] == "--":
        cmd = cmd[1:]

    start_time = time.time()
    attempt = 0
    fails = 0

    while True:
        attempt += 1
        print(f"\n🚀 Test attempt #{attempt} …", file=sys.stderr)

        # Launch the process
        proc = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            bufsize=1,
            universal_newlines=True
        )

        # Shared state for last‐output timestamp
        last_output = time.time()

        # Watchdog thread
        def watchdog():
            nonlocal last_output
            while proc.poll() is None:
                now = time.time()
                # total timeout
                if now - start_time >= args.timeout:
                    print(
                        f"⏱️  Wall-clock timeout ({args.timeout}s) reached; "
                        "terminating test runner",
                        file=sys.stderr
                    )
                    proc.terminate()
                    return
                # idle timeout
                if now - last_output >= args.idle:
                    print(
                        f"🤐 No output for {args.idle}s; killing test runner",
                        file=sys.stderr
                    )
                    proc.terminate()
                    return
                time.sleep(0.5)

        thread = threading.Thread(target=watchdog, daemon=True)
        thread.start()

        # Pump stdout ‑ whenever we see a line, reset last_output
        for line in proc.stdout or []:
            sys.stdout.write(line)
            sys.stdout.flush()
            last_output = time.time()

        exit_code = proc.wait()
        if exit_code == 0:
            print(f"\n✅ Tests passed on attempt #{attempt}", file=sys.stderr)
            sys.exit(0)
        else:
            elapsed = time.time() - start_time

            if elapsed >= args.timeout:
                print(
                    f"\n❌ Tests failed and wall-clock timeout ({args.timeout}s) "
                    "exceeded",
                    file=sys.stderr
                )
                sys.exit(exit_code)
            elif exit_code == signal.SIGTERM:
                print(
                    f"\n⚠️  Tests terminated on attempt #{attempt}, "
                    "retrying…",
                    file=sys.stderr
                )
            else:
                fails += 1
                if fails >= args.retries:
                    print(
                        f"\n❌ Tests failed on attempt #{attempt} "
                        f"and exceeded retry limit ({args.retries})",
                        file=sys.stderr
                    )
                    sys.exit(exit_code)
                else:
                    print(
                        f"\n⚠️  Tests failed on attempt #{attempt}, "
                        "retrying…",
                        file=sys.stderr
                    )

if __name__ == "__main__":
    main()
