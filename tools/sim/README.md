# Balance simulator

Models a commuter player (two 15-minute sessions + two 2-minute peeks a day,
1.5 taps/s, greedy best-payback buying) to check pacing.

```bash
python3 tools/sim/sim.py          # no-ads player: day and active minutes per rank
python3 tools/sim/sim.py --ads    # player who watches ~6 rewarded ads a day
python3 tools/sim/tune.py         # solve rank requirements for TARGET_DAYS
```

`economy.py` holds every balance constant. The Godot code must mirror it;
a test will compare outputs.
