# KarabinerCompose

KarabinerCompose generates a Karabiner-Elements complex modification rule for a small compose key setup. The default profile uses Right Command as the compose key and outputs common Latin and IPA characters through the clipboard.

## Generate

```sh
swift run karabiner-compose > right-command-compose.json
```

## Enable in Karabiner-Elements

Copy the generated file into Karabiner-Elements:

```sh
mkdir -p ~/.config/karabiner/assets/complex_modifications
cp right-command-compose.json ~/.config/karabiner/assets/complex_modifications/
```

Then open Karabiner-Elements:

1. Open **Complex Modifications**.
2. Click **Add predefined rule**.
3. Enable **Right Command Compose**.

Remove any Simple Modification that remaps `right_command`; this rule needs to receive Right Command directly.

## Use

Tap and release Right Command, then type a compose sequence:

```text
Right Command, ', a -> á
Right Command, a, e -> æ
Right Command, l, e -> ɛ
```
