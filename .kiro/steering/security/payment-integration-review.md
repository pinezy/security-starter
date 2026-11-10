---
inclusion: auto
name: payment-integration-review
description: Use when Stripe, PayPal, or other payment code changed, to check for hardcoded keys, webhook signature verification, and amount tampering.
---

# Payment integration review playbook

## When to use this
Any time Stripe/PayPal/etc. code is added or changed. Mistakes here cost
real money, directly.

## Core checks

- **Keys never hardcoded.** Already covered by `secret-scanning`, but double
  check: test keys (`sk_test_...`) and live keys (`sk_live_...`) both count.
- **Webhook signatures verified.** Every payment webhook handler must verify
  the provider's signature header before trusting the payload. Without this,
  anyone can POST a fake "payment succeeded" event to your webhook URL.
- **Amount determined server-side.** The price/amount charged must come from
  your own server/database, never trusted from a value the client sent
  (classic bug: client sends `{"amount": 1}` and server charges that).
- **Idempotency keys used** on charge creation, so a retried request (double
  click, network retry) doesn't double-charge.

## What a false positive looks like
A sandbox/test-mode integration with test keys only, not yet connected to
real money, in a repo that's never deployed with live keys. Still worth
fixing before going live, but not an active financial risk yet.

## Fixing it
Check the provider's SDK docs for the signature-verification helper
(e.g. Stripe's `stripe.webhooks.construct_event`) and use it rather than
writing your own verification.
