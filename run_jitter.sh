#!/bin/bash
# Run gmacs.exe (via Whisky's wine64) in every "*/jitter/*/" directory that
# doesn't already have a Gmacsall.out file. Uses N parallel chains, each
# pinned to its own WINEPREFIX (concurrent wine on the same prefix
# deadlocks via wineserver). Resumable: re-running skips finished iterations.
#
# Override parallelism with: N_PARALLEL=4 bash run_jitter.sh

set -o pipefail

WHISKY_WINE="$HOME/Library/Application Support/com.isaacmarovitz.Whisky/Libraries/Wine/bin/wine64"
WHISKY_PREFIX="$HOME/Library/Containers/com.isaacmarovitz.Whisky/Bottles/AD8FC922-1B19-4B6C-92DB-A4699F0AC94B"
SLOT_BASE="$(pwd)/.wine_slots"

# --- Parallelism: default to perf-core count (Apple Silicon) or ncpu/2,
# capped at 6 (the practical sweet spot for wine + a long-lived gmacs run).
DEFAULT_N=$(sysctl -n hw.perflevel0.physicalcpu 2>/dev/null \
            || sysctl -n hw.ncpu 2>/dev/null \
            || echo 4)
DEFAULT_N=$(( DEFAULT_N > 6 ? 6 : DEFAULT_N ))
DEFAULT_N=$(( DEFAULT_N < 1 ? 1 : DEFAULT_N ))
N_PARALLEL="${N_PARALLEL:-$DEFAULT_N}"

# --- Sanity checks
if [[ ! -x "$WHISKY_WINE" ]]; then
  echo "ERROR: wine64 not found at $WHISKY_WINE" >&2
  exit 1
fi
if [[ ! -d "$WHISKY_PREFIX" ]]; then
  echo "ERROR: Whisky prefix not found at $WHISKY_PREFIX" >&2
  exit 1
fi

# --- Ensure N_PARALLEL wine prefix slots exist (APFS clones, ~free on disk)
mkdir -p "$SLOT_BASE"
s=1
while [[ "$s" -le "$N_PARALLEL" ]]; do
  if [[ ! -d "$SLOT_BASE/slot_$s" ]]; then
    echo "Creating wine slot $s (one-time APFS clone)..."
    cp -Rc "$WHISKY_PREFIX" "$SLOT_BASE/slot_$s"
  fi
  s=$((s + 1))
done

# --- Collect iteration dirs
WORK_DIRS=()
while IFS= read -r line; do
  WORK_DIRS+=("$line")
done < <(find . -mindepth 3 -maxdepth 3 -type d -path "*/jitter/*" | sort)

total=${#WORK_DIRS[@]}
done_count=0
todo_count=0
for d in "${WORK_DIRS[@]}"; do
  if [[ -f "$d/Gmacsall.out" ]]; then
    done_count=$((done_count + 1))
  else
    todo_count=$((todo_count + 1))
  fi
done
echo "Found $total iter dirs ($done_count done, $todo_count todo). Running $N_PARALLEL chains in parallel."

if [[ "$todo_count" -eq 0 ]]; then
  echo "Nothing to do."
  exit 0
fi

# --- Per-chain runner (sequential within the chain, dedicated slot)
run_chain() {
  local slot=$1
  shift
  local prefix="$SLOT_BASE/slot_$slot"
  local d t0 rc elapsed
  for d in "$@"; do
    if [[ -f "$d/Gmacsall.out" ]]; then
      continue
    fi
    if [[ ! -f "$d/gmacs.exe" || ! -f "$d/gmacs.dat" ]]; then
      echo "[slot $slot] SKIP $d (missing gmacs.exe or gmacs.dat)" >&2
      continue
    fi
    echo "[slot $slot] RUN  $d"
    t0=$(date +%s)
    (
      cd "$d" || exit 1
      WINEPREFIX="$prefix" WINEDEBUG=-all \
        "$WHISKY_WINE" gmacs.exe -nohess -verbose 0 -nox \
        > gmacs_log.txt 2>&1
    )
    rc=$?
    elapsed=$(( $(date +%s) - t0 ))
    if [[ -f "$d/Gmacsall.out" ]]; then
      echo "[slot $slot] DONE $d  (${elapsed}s, rc=$rc)"
    else
      echo "[slot $slot] FAIL $d  (${elapsed}s, rc=$rc, no Gmacsall.out)" >&2
    fi
  done
}

# --- Round-robin dispatch: chain N gets indices N, N+N_PARALLEL, N+2*N_PARALLEL, ...
s=1
while [[ "$s" -le "$N_PARALLEL" ]]; do
  chain_dirs=()
  i=$((s - 1))
  while [[ "$i" -lt "$total" ]]; do
    chain_dirs+=("${WORK_DIRS[$i]}")
    i=$((i + N_PARALLEL))
  done
  if [[ ${#chain_dirs[@]} -gt 0 ]]; then
    run_chain "$s" "${chain_dirs[@]}" &
  fi
  s=$((s + 1))
done

wait
echo "All chains finished."
