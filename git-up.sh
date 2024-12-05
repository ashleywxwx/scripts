#!/bin/bash

git fetch origin main:main
git merge origin main --commit --no-edit
git push
