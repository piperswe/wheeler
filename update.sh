#!/usr/bin/env bash

set -euxo pipefail

nix flake update --commit-lock-file
git push
sudo nixos-rebuild --flake . boot --builders '' --show-trace
