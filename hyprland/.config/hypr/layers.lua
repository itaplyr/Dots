-- ── Layer Rules ────────────────────────────────────────────
-- Disable animation for fuzzel (instant disappear)

hl.layer_rule({ match = { namespace = "fuzzel" }, no_anim = true })
