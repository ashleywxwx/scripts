#!/bin/sh

# Displays any Argo CD Application that are not Synced or Healthy

argocd --grpc-web app list | grep -E 'OutOfSync|Unknown|Progressing|Suspended|Degraded|Missing' | awk '{print substr($1, 8), $5, $6}' | column -t
