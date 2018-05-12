#!/usr/bin/env bash

echo save post
git add . && git commit -m "[deploy] add post" && git push origin hugo

