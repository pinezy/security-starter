---
inclusion: auto
name: file-upload-review
description: Use when a file upload endpoint changed, to check file type validation, size limits, storage path, and execution risk.
---

# File upload review playbook

## When to use this
Any time an endpoint accepts a file (avatar upload, document upload, CSV
import, etc). Full checklist:
`.kiro/security-assets/checklists/file-upload-checklist.md`

## Core checks

- **Type validation by content, not just extension.** Checking the magic
  bytes / MIME sniff, not just trusting `filename.endswith('.png')`, which
  is trivial to spoof.
- **Size limit enforced server-side,** not only in frontend JS.
- **Storage location is not web-executable.** Uploaded files shouldn't land
  in a directory the web server will execute as code (classic: uploading a
  `.php`/`.py` file into a public web root).
- **Filename sanitized.** Strip path traversal (`../../etc/passwd`-style
  names) and don't trust the client-provided filename for the stored path;
  generate your own name/ID.
- **Virus/malware scanning** for anything re-shared to other users, if
  feasible for the project's scale.

## What a false positive looks like
A hackathon demo that only accepts uploads from the logged-in user for their
own private use, with no re-sharing to others and a tiny hardcoded size
limit, carries much lower risk than a public multi-user upload feature.
Scale the rigor to who else can be affected.

## Fixing it
See `.kiro/security-assets/checklists/file-upload-checklist.md` for
language-specific snippets (Python/Node) for safe filename generation and
content-type sniffing.
