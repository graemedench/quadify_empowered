# FM4 build notes

## Front-panel IR conversion

The original **LED 8** position is reused as the visible opening for the
HS0038 IR receiver.

- LED 8 is **not disconnected**: its MCP23017 connection remains intact.
- The LED itself is pulled back behind the front panel so it does not occupy
  the opening or shine directly through the receiver position.
- The HS0038 receiver is mounted in the old LED-8 opening, with its OUT pin on
  Raspberry Pi GPIO27 (physical pin 13), VCC on 3.3 V and GND on ground.

This keeps the eight-channel LED hardware reversible while giving the IR sensor
a neat, front-facing location.

## Included mounting parts

The current printable front-panel mounting parts are in
[`FM4 Mounting Parts`](../FM4%20Mounting%20Parts/): screen holder, rotary-knob
bracket and knob extender. Back-panel parts are deliberately not included yet.
