#!/usr/bin/env bash

set -euxo pipefail

nix flake update --commit-lock-file
git push
sudo nixos-rebuild --flake . switch --builders '' --show-trace
