#!/usr/bin/env bash

echo save post
git add . && git commit -m "add post" && git push origin hugo

echo deploy site...
hugo

cd public/ || exit
git add . && git commit -m "add content" && git push origin gh-pages

