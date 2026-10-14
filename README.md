# OCL: set up a new Mac (or a new macOS account)

Needs Homebrew ([brew.sh](https://brew.sh)), then Ansible and the GitHub CLI:
```
brew install ansible gh
```

Second macOS account (Homebrew belongs to another user): load brew first.
```
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Run the setup.** Rerun the same line after anything it asks you to do.
```
ansible-pull -U https://github.com/One-Connected-Life/setup.git
```

Not signed in to GitHub yet? It stops and prints this line (Sam signs in as
`oneconnectedlife`); run it, then the setup line again:
```
gh auth login -s admin:public_key,workflow
```

It then clones the private `ocl` repo into `~/coding/ocl` (an existing checkout
fast-forwards when it is clean, on `main` and behind; otherwise it runs as is) and runs its `mac-setup/playbook.yml` with tags `base,ocl,chrome`
(GitHub login `bluemihai`: everything). Add `-t <tags>` to choose, `--check`
for a dry run. It prints `Running as: staff` or `Running as: collaborator`,
then a checklist of the manual steps left.

Full guide (needs the GitHub login):
https://github.com/One-Connected-Life/ocl/blob/main/mac-setup/README.md
