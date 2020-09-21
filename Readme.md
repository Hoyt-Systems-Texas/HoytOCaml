# Inline Tests Working

Add the following line to .merlin file:

```
FLG -ppx 'ppx-jane -as-ppx -inline-test-lib bap'
```