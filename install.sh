#!/bin/bash
curl https://mise.run | sh
"$HOME/.local/bin/mise" trust
"$HOME/.local/bin/mise" run install
