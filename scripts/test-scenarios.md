# Heropedia Office Hour — manual test scenarios

Walk through each scenario in a fresh Claude Code session with this plugin installed. For each: state the input, the expected phase sequence, and the verifiable side effects. Mark ✅ / ❌ as you go.

## Scenario 1: Canonical-path session (once a persona has a `## Office Hour Questions` section)

**Setup (skip until at least one persona has canonical questions live):** ensure `getDetail` for the chosen hero returns markdown containing `## Office Hour Questions`.

**Input:** "Let Warren Buffett hold office hours on my SaaS pricing."

**Expected sequence:**
1. Skill routes to `heropedia-office-hour` (not the sibling `heropedia`).
2. Phase 0: `getListByHero` for Buffett → matches → possibly AskUserQuestion for role → `getDetail`.
3. Phase 0.5: canonical section parsed, `session.source = "canonical"`.
4. Phase 1: hero-voiced framing, asks for topic.
5. Phase 2: exactly the canonical questions asked, one at a time, in order.
6. Phase 3: premise challenge fires.
7. Phase 4: diagnosis + one-week action + red flag.
8. Phase 5: `~/.heropedia/office-hours/YYYY-MM-DD-warren-buffett-saas-pricing.md` written.
9. Phase 5b: if inside a git repo, offers project copy.
10. Phase 6: **skipped** (canonical source).

**Verify on disk:**
```bash
ls -la ~/.heropedia/office-hours/ | tail -5
head -20 ~/.heropedia/office-hours/*warren-buffett*.md
```
Expect: a file exists; `Source: canonical` appears in the header; no file under `pending-share/`.

## Scenario 2: Distilled-path session (persona has no curated questions)

**Input:** "Office hour with Ni Haixia on my chronic back pain."

**Expected sequence:**
1. Same routing.
2. Phase 0: persona resolved.
3. Phase 0.5: no `## Office Hour Questions` section → runtime distillation → `session.source = "distilled"`.
4. Phase 1–4: as above, questions reflect Ni Haixia's TCM diagnostic framework (Yin-Yang, meridians, pulse) — NOT YC startup questions.
5. Phase 5: notes written; `Source: distilled` in header.
6. Phase 6: **fires** — asks about sharing questions.

**Verify Phase 6 opt-in flow:**
- Say "yes" → check `~/.heropedia/office-hours/pending-share/*.json` exists and contains hero_id, questions array, no user data.
- Alternate: say "no" → no file appears under `pending-share/`.

**Privacy check:**
```bash
grep -riE 'back pain|chronic' ~/.heropedia/office-hours/pending-share/ 2>/dev/null || echo "clean"
```
Expect: `clean` (no user topic strings in shared JSON).

## Scenario 3: Trigger routing — no false positives to `heropedia-office-hour`

**Input:** "Ask Warren Buffett to look at my deck."

**Expected:** routes to the sibling `heropedia` skill (single-turn), NOT to `heropedia-office-hour`. Reply is one turn, no phase machinery.

## Scenario 4: Trigger routing — `office hour` phrase wins even inside "ask X to…"

**Input:** "Ask Warren Buffett to hold office hours on my deck."

**Expected:** routes to `heropedia-office-hour` (because "office hour" appears). Deference rule in the existing `heropedia` skill fires.

## Scenario 5: Escape hatch mid-Phase-2

**Input:** start a session, answer Q1 substantively, then reply to Q2 with "just do it, skip the questions."

**Expected:**
1. Hero says (in-persona) "Two more, then I move."
2. Two questions asked.
3. If user pushes back again → Phase 3 immediately.
4. Phase 4 delivers a truncated diagnosis acknowledging limited data.
5. Notes file records `escape_triggered` state (via the omitted questions).

## Scenario 6: Non-git CWD

**Input:** start a session from `~/` (or any non-repo directory).

**Expected:** Phase 5 writes the notes file; Phase 5b is silently skipped (no copy prompt). Phase 6 fires or skips per source, independently of git state.

## Scenario 7: Ambiguous topic

**Input:** "Office hour with Dieter Rams on my design work."

**Expected:** Phase 1 asks once for a specific artifact ("Which page? Which product? Show me one screen."). If user still abstract, proceeds anyway — does not loop forever.

## Scenario 8: MCP disconnected

**Setup:** temporarily break the MCP connection (rename `.mcp.json` or use a bogus URL).

**Input:** "Let Buffett hold office hours on my deck."

**Expected:** skill reports the MCP failure explicitly, tells user to run `claude mcp list`, and stops. Does NOT fabricate Buffett's questions.

**Cleanup:** restore `.mcp.json`.

---

## Sign-off

- [ ] Scenario 1 ran ✅ (or documented reason skipped — canonical not yet live)
- [ ] Scenario 2 ran ✅
- [ ] Scenario 3 ran ✅
- [ ] Scenario 4 ran ✅
- [ ] Scenario 5 ran ✅
- [ ] Scenario 6 ran ✅
- [ ] Scenario 7 ran ✅
- [ ] Scenario 8 ran ✅
