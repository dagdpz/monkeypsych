# Issues (quirks / inconsistencies / mistakes)

Living list of known bugs, brittle paths, and design inconsistencies.  
Do **not** treat this as a changelog of intended behavior. Items tagged **ABI** affect saved `.mat` / TDT / ma1 — fix with care.

Status: `open` | `wontfix` | `fixed`  
Priority is informal: **P0** data/hardware wrong · **P1** wrong UX / easy footgun · **P2** cleanup / tech debt.

---

## Sound

| ID | Pri | Status | Issue |
|----|-----|--------|-------|
| S1 | P1 | open | `Sounds/mp_Sounds.m` loads `[SETTINGS.MP_PATH filesep 'failure.wav']` / `reward.wav` — i.e. **repo root**. WAVs actually live in `Sounds/`. XBI_sounds fails unless files are duplicated at root. |
| S2 | P2 | open | Setup1 leftover **`Sounds.m`** in toolbox root (`function Sounds`, `wavread`, hard path `D:\Sources\MATLAB\monkeypsych_3.0\…`). Not on current master; do not resurrect. Current call sites use `mp_Sounds`. |
| S3 | P2 | open | `wavread` is gone in modern MATLAB; any revived legacy sound helper must use `audioread`. |
| S4 | P2 | open | `SETTINGS.SoundType` / per-event sound flags are set in `get_monkey` / `get_setup` and then often **overwritten** by condition files — easy to think you changed the wrong place. |

---

## Coordinates / display

| ID | Pri | Status | Issue |
|----|-----|--------|-------|
| C1 | P1 | open / note | `deg2pix_xy` uses `vd*tan(θ)` on **absolute** screen-centered deg. Equal ±E around a shifted FP → **unequal cm on glass**, equal visual angle from FP if head is at screen center. Not a bug if that is the intended model; document it. |
| C2 | P1 | open | `pix2deg_xy` uses `2*atan((cm/2)/vd)` — **not** the inverse of current `deg2pix_xy`. Touch / mouse-as-eye paths disagree with drawn stimuli. |
| C3 | P0 | open | `aux_FillPar`: after converting size with `deg2pix_withOffset(stim(3),…)`, does `stim(4)=deg2pix_withOffset(stim(3),…)` — **radius from already-pixel size**. Drawn window ≠ intended deg (behavior still uses `par.deg.radius`). |
| C4 | P1 | open | `deg2pix_withOffset` scales size by eccentricity from **screen center**, so outer choice target is drawn larger than inner for the same `size` deg — can look like L/R asymmetry under array shift. |
| C5 | P2 | open | Three deg↔cm conventions coexist (`tan`, `2*atan(cm/2)`, eccentricity-corrected size). No single documented screen geometry. |

---

## Hardware / setup drift

| ID | Pri | Status | Issue |
|----|-----|--------|-------|
| H1 | P0 | **fixed** | NI device id is `SETTINGS.DAQ_device` in `get_setup` (default `Dev1`; **setup 1 = `Dev2`**). `monkeypsych.m` and `Calibrations/` use it for ai/ao/do. MCC ignores it. |
| H2 | P1 | **fixed** | Case 1 taken from setup1 snapshot: GUI coords, touchscreen on, IK 20230125 touch cal (overwrites Danial), x_threshold −4.2. `DAQ_device=Dev2` kept. |
| H3 | P1 | **fixed** | Case 3 taken from setup1 snapshot: screen 53×30 cm, GUI on primary `[150 400…]`. `DAQ_device=Dev1` kept. |
| H4 | P0 | open | Legacy DAQ API (`analoginput` / `digitalio` / `putvalue`) — broken on current Data Acquisition Toolbox. |
| H5 | P0 | open | `io32` / inpout32 parallel port — fragile on 64-bit Windows. |
| H6 | P2 | open | `SETTINGS.dag_drive` network copy on close can fail; local run file is source of truth, errors are soft. Close now `disp`s the server mkdir path before creating it. |

---

## Conditions / subjects / paths

| ID | Pri | Status | Issue |
|----|-----|--------|-------|
| P1 | P0 | open | Conditions split to `monkeypsych_conditions`, but many `get_monkey` paths still `D:\Sources\MATLAB\monkeypsych_3.0\conditions\…`. |
| P2 | P1 | **fixed** | `get_monkey` matched to setup1: Linus/Curius → `monkeypsych_conditions`; subjects Feno/Quentin/Toadie; Curius setup3 vd=35 / uh=10. Pinocchio case dropped (was master-only). |
| P3 | P1 | open | `Debug_IKDAG` points at `monkeypsych\conditions\…` which no longer exists in this repo. |
| P4 | P2 | open | Condition scripts `run()` into controller workspace (`eval`-class coupling). |
| P5 | P2 | open | `All.*` field **order** = TDT classifier byte order — undocumented contract, easy to break by reordering fields. |

---

## Controller logic / UX

| ID | Pri | Status | Issue |
|----|-----|--------|-------|
| L1 | P1 | **fixed** | F2 radius override now writes `task.eye.tar(k).radius` for **all** existing targets (was tar(1) on master, tar(2) on setup1). |
| L2 | P1 | open | Requested loop rate `fsMatlab=1000` is not achieved; sampling ~400–1200 Hz, not stored in `.mat`. |
| L3 | P1 | open | `memoryBuffer` sized for 20 s × 1 kHz; no hard guard if `counterLine` exceeds `bufferSize`. |
| L4 | P2 | open | Type 12 skips `FIX_HOL` in `state_transition` — easy to “regularize” wrongly. |
| L5 | P1 | open | SUCCESS can become ABORT if wrong target (`completed==1`, `success==0`) — ma1 must use both flags. |
| L6 | P2 | open | `task.fraction_choice` in `get_monkey` is overwritten every trial by condition `instructed_choice_con`. |
| L7 | P2 | open | Esc / `ListenChar(2)` / `Priority(2)` — error paths may skip `sca; ListenChar(0)`. |

---

## Data / versioning / repo hygiene

| ID | Pri | Status | Issue |
|----|-----|--------|-------|
| D1 | P2 | open | `autosave_changed_monkeypsych` copies whole controller into `all_monkeypsych_versions/` — not real VCS; ignore for diffs. |
| D2 | **ABI** | open | `STATE` codes duplicated in `monkeypsych.m` and `ma1/ma1_task_state_dictionary.m` — can drift. |
| D3 | **ABI** | open | `states_onset` absolute; `reward_time` is valve duration; `microstim_start` relative to state entry — easy to misread. |
| D4 | P2 | open | README was expanded; wiki mostly empty / stale paths. |
| D5 | P2 | open | `Calibrations/` added from setup1 (touch/pump/IO helpers) — not wired into run path; docs TBD. |

---

## Suggested fix order (when we start)

1. **S1** sound WAV path (+ document S2 as deleted legacy)  
2. ~~**H1** DevN from `get_setup`~~ **fixed** (`SETTINGS.DAQ_device`; setup 1 = `Dev2`)  
3. **P1** conditions root / path hygiene  
4. **C3** `aux_FillPar` radius (verify on screen)  
5. **C2** make `pix2deg` inverse of `deg2pix` (recalibrate touch if needed)  
6. Document **C1/C4** geometry before changing tan model  
7. Split `monkeypsych.m` / DAQ modernization later  

---

## Changelog of this list

- 2026-08-18: started; sound paths; coord/display; setup1 vs master drift; conditions; controller; ABI notes.
- 2026-08-18: H1 fixed — `SETTINGS.DAQ_device` (setup 1 = Dev2).
- 2026-08-18: H2/H3 — case 1 and 3 `get_setup` restored from setup1 snapshot.
- 2026-08-18: P2 — `get_monkey` updated from setup1 (Feno/Quentin/Toadie, conditions paths).
- 2026-08-18: renamed QUIRKS.md → Issues.md.
- 2026-08-18: L1 fixed — F2 sets radius on all `task.eye.tar`; server mkdir prints create path.
- 2026-08-18: `SETTINGS.eyecal` — condition file can override eye-cal `.mat` path (default `{DATA_PATH}\last_eyecal.mat`).
