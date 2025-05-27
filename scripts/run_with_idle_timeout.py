import argparse
import os
import shlex
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
                    os.kill(proc.pid, signal.SIGUSR2)
                    return
                # idle timeout
                if now - last_output >= args.idle:
                    print(
                        f"🤐 No output for {args.idle}s; killing test runner",
                        file=sys.stderr
                    )
                    os.kill(proc.pid, signal.SIGUSR1)
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

        # killed by us for idle
        if exit_code == -signal.SIGUSR1:
            print(f"\n💤 Idle timeout kill (code {exit_code}); retrying…",
                  file=sys.stderr)
            continue  # go back and try again (unless total timeout)

        # killed by us for overall timeout
        if exit_code == -signal.SIGUSR2:
            print(f"\n⏱️  Overall timeout kill (code {exit_code}); giving up",
                  file=sys.stderr)
            sys.exit(1)

        # any other non-zero is a real test failure
        print(f"\n❌ Tests failed on attempt #{attempt} "
              f"(exit code {exit_code})", file=sys.stderr)
        sys.exit(exit_code)

if __name__ == "__main__":
    main()
