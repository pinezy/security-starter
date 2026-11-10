# File upload checklist (hard asset for `file-upload-review`)

## Validate by content, not extension

```python
# Python: sniff real content type instead of trusting the filename
import filetype
kind = filetype.guess(file_bytes)
if kind is None or kind.mime not in ("image/png", "image/jpeg"):
    raise ValueError("Unsupported file type")
```

```js
// Node: file-type package does the same thing
const { fileTypeFromBuffer } = require("file-type");
const type = await fileTypeFromBuffer(buffer);
if (!type || !["image/png", "image/jpeg"].includes(type.mime)) {
  throw new Error("Unsupported file type");
}
```

## Generate your own filename, never trust the client's

```python
import uuid, os
ext = ".png"  # derived from the sniffed type above, not the client's filename
stored_name = f"{uuid.uuid4()}{ext}"
```

## Enforce size limits server-side

```js
// Express + multer example
const upload = multer({ limits: { fileSize: 5 * 1024 * 1024 } }); // 5MB
```

## Store outside the web-executable path
Uploaded files should live in a directory (or object storage bucket) that
the web server will never execute as code, and ideally isn't under the
public web root at all — serve them through a controlled route/signed URL
instead of a direct static path.

## If files are shared with other users
Consider a malware scan step (e.g. ClamAV, or a cloud provider's built-in
scanning) before the file is made available to anyone besides the uploader.
