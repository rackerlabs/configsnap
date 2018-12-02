#!/usr/bin/env bash

NVER="${1:?Missing version number}"

sed -ri 's/(version\s+=\s+).*/\1"'"$NVER"'"/' configsnap
sed -ri 's/(Version:\s+)[0-9]+\..*/\1'"$NVER"'/' configsnap.spec

vim configsnap.spec
