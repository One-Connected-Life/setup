# OCL: set up a new Mac (or a new macOS account)

Open Terminal and paste each block, one at a time.

**1. Homebrew** (skip if `brew --version` already works)
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**2. Ansible + GitHub CLI**
```
brew install ansible gh
```

**3. Sign in to GitHub** (your own login; Sam uses `oneconnectedlife`)
```
gh auth login -s admin:public_key,workflow && gh auth setup-git
```

**4. Run the setup**
```
ansible-pull -U https://github.com/One-Connected-Life/ocl.git --full \
  -d ~/coding/ocl mac-setup/playbook.yml --tags base,ocl,chrome
```

It prints `Running as: staff` or `Running as: collaborator`, then a checklist of the
manual steps left. Full guide (needs the GitHub login):
https://github.com/One-Connected-Life/ocl/blob/main/mac-setup/README.md
