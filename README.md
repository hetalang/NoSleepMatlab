# NoSleepMatlab
Matlab tool to prevent sleep mode

Prevent your computer from going to sleep while MATLAB is running long tasks — and automatically restore normal system behavior when the task finishes or fails.

- **Cross-platform backend**  
  - Windows: `PowerRequest`  
  - macOS: `caffeinate`  
  - Linux: `systemd-inhibit`
- **Simple API**: block-style or manual on/off.
- **Safe by design**: the sleep-inhibit request is always released on exit or error.
- Optional **keep_display** mode to prevent the screen from turning off.

## Installation

1. Download the latest release file **`NoSleep.mltbx`** from  
   <https://github.com/hetalang/NoSleepMatlab/releases>

2. Install by double-clicking the `.mltbx` file  
   **or** run:

```matlab
matlab.addons.install('NoSleep.mltbx');
```

After installation:

```matlab
import NoSleep.*
```

## Usage

### Basic usage

```matlab
nosleep_on();
% long-running MATLAB code here
nosleep_off();
```

### Block-style usage

`with_nosleep` runs a function while sleep-prevention is active and restores normal behavior afterwards:

```matlab
with_nosleep(@() myLongComputation());
```

## Options

### keep_display

Prevents the display from turning off (default: `false`):

```matlab
nosleep_on('keep_display', true);
```

Block-style:

```matlab
with_nosleep(@() myLongComputation(), ...
             'keep_display', true);
```

## Known limitations and recommendations

Some sleep behaviors are enforced by the operating system and **cannot** be overridden by MATLAB or this toolbox.

1. **Closing the laptop lid or pressing the power button** forces sleep regardless of active PowerRequest or other inhibit mechanisms.

2. On Windows devices with **Modern Standby (S0ix) on battery power**, the OS may ignore sleep-prevention signals after ~5 minutes of inactivity when the display is off.
   - Plugging into **AC power** avoids this behavior.  
   - Alternatively, use `'keep_display', true` to keep the screen awake.

## Related packages

- **NoSleepR** — <https://github.com/hetalang/NoSleepR>  
  R implementation using system-level sleep-inhibit APIs.

- **NoSleep.jl** — <https://github.com/hetalang/NoSleep.jl>  
  Julia implementation with the same backend logic (Windows/macOS/Linux).

## Author

- [Evgeny Metelkin](https://metelkin.me)

## License

MIT (see `LICENSE.md`). 
