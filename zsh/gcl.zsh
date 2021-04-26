#!/usr/bin/env zsh

# gcl: git-cleanup-remote-and-local-branches
#
# Cleaning up remote and local branch is delivered as follows:
# 1. Prune remote branches when they are deleted or merged
# 2. Remove local branches when their remote branches are removed
# 3. Remove local branches when a master included squash and merge commits
#
# Thanks to: https://blog.takanabe.tokyo/en/2020/04/remove-squash-merged-local-git-branches/

function git_prune_remote() {
  echo "Start removing out-dated remote merged branches"
  git fetch --prune
  echo "Finish removing out-dated remote merged branches"
}

function git_remove_merged_local_branch() {
  echo "Start removing out-dated local merged branches"
  git branch --merged | egrep -v "(^\*|master|ANY_BRANCH_YOU_WANT_TO_EXCLUDE)" | xargs -I % git branch -d %
  echo "Finish removing out-dated local merged branches"
}

# When we use `Squash and merge` on GitHub,
# `git branch --merged` cannot detect the squash-merged branches.
# As a result, git_remove_merged_local_branch() cannot clean up
# unused local branches. This function detects and removes local branches
# when remote branches are squash-merged.
#
# There is an edge case. If you add suggested commits on GitHub,
# the contents in local and remote are different. As a result,
# This clean up function cannot remove local squash-merged branch.
function git_remove_squash_merged_local_branch() {
  echo "Start removing out-dated local squash-merged branches"
  git checkout -q master &&
    git for-each-ref refs/heads/ "--format=%(refname:short)" |
    while read branch; do
      ancestor=$(git merge-base master $branch) &&
        [[ $(git cherry master $(git commit-tree $(git rev-parse $branch^{tree}) -p $ancestor -m _)) == "-"* ]] &&
        git branch -D $branch
    done
  echo "Finish removing out-dated local squash-merged branches"
}

# Clean up remote and local branches
function gcl() {
  git_prune_remote
  git_remove_merged_local_branch
  git_remove_squash_merged_local_branch
}

gcl

