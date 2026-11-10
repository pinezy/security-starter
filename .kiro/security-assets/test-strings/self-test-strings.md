# Self-test strings (hard asset, use only against your own local app)

These are safe strings to paste into YOUR OWN app's forms, while it's
running on your own machine or your own staging environment, to confirm
your output encoding and input handling work. Never send these to a site
you don't own or don't have written authorization to test.

## XSS (confirms output is escaped, not executed)
```
<script>alert('xss-test')</script>
"><img src=x onerror=alert('xss-test')>
'><svg onload=alert('xss-test')>
```
Expected safe result: the literal text appears on the page (e.g. as visible
text), and no alert box pops up. If an alert fires, the output isn't being
escaped before being rendered as HTML.

## SQL injection (confirms queries are parameterized)
```
' OR '1'='1
'; DROP TABLE users; --
1' UNION SELECT NULL,NULL,NULL--
```
Expected safe result: treated as a literal search string with no matches
(or a clean validation error), never a database error message or unexpected
extra rows returned.

## Path traversal (confirms filenames/paths are sanitized)
```
../../etc/passwd
..\..\..\windows\win.ini
```
Expected safe result: rejected, or resolved safely within the intended
directory, never a file from outside the intended folder.

## After testing
Delete any test records these create from your database/storage, the same
way you'd clean up the fake-secret demo.
