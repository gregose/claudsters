---
name: design-docs
description: Updates SpeedsterAI documentation (claude.md, README.md, analysis.md) after design changes and handles git commits. Use this skill whenever the user says "update docs", "document this change", "commit", "update the readme", "update claude.md", "update analysis", or after completing a design change that affects enclosure parameters, geometry, or validation results. Also use when the user asks what needs documenting or wants to review what changed. This skill should be triggered after any significant design modification to keep all three documentation files in sync.
---

# Design Docs — SpeedsterAI Documentation Sync

After each major design change to the SpeedsterAI enclosure, three documentation files must be updated to maintain project continuity. This skill knows the structure of each file and which sections are affected by different types of changes.

## Why All Three Files Matter

- **`claude.md`** — AI agent context. Future AI sessions read this to understand the full design history. If it's stale, the next agent will make mistakes or repeat solved problems.
- **`README.md`** — Public-facing documentation. Users and collaborators read this for specs, BOM, and assembly instructions.
- **`analysis.md`** — Design verification. Proves the design is mechanically sound and acoustically faithful. If a parameter changes, the analysis must reflect the new values.

## File Structures

### claude.md — AI Agent Context

```
# SpeedsterAI — Design Context for AI Agents
## Project Overview
## Design Sessions (Chronological)
  ### Session N: [Title]
    - Problems identified
    - Solutions applied
    - What stayed the same
## Current Locked Parameters (table)
## File Structure
## Key Implementation Notes for Agents
## Open Items / Future Work
```

**What to update after a design change:**
1. **Add a new Design Session** entry with the next session number. Include: problem statement, solution, parameter changes, what stayed the same.
2. **Update the Locked Parameters table** if any values changed.
3. **Update Key Implementation Notes** if new patterns or rules were established.
4. **Update Open Items** if items were resolved or new ones identified.

### README.md — Public Documentation

```
# SpeedsterAI — 3D Printed Speedster Speaker Enclosure
## Specifications (comparison table: Original vs SpeedsterAI)
## Drivers
## Design Features
## Renders (image grid)
## STL Downloads
## Using the SCAD File
  ### Rendering / Exporting / Adjusting Volume / Validating
## Print Settings
## Assembly Instructions
## Bill of Materials
## Airtightness Test
## File Structure
## Development Container
```

**What to update after a design change:**
1. **Specifications table** — if any dimensions, volumes, or measurements changed
2. **Design Features** — if a new feature was added or an existing one modified
3. **Print Settings** — if print orientation or support requirements changed
4. **Assembly Instructions** — if the assembly sequence changed
5. **Bill of Materials** — if hardware counts or specs changed
6. **Render images** — only if new renders were generated (they're auto-linked from `renders/`)

### analysis.md — Design Verification

```
# Design Analysis — SpeedsterAI
## 1. Acoustic Fidelity to Carmody's Design
  ### 1.1 Internal Volume
  ### 1.2 Port Tuning
  ### 1.3 Baffle Diffraction
  ### 1.4 Driver Spacing and Crossover Compatibility
  ### 1.5 Woofer Depth Clearance
  ### 1.6 Port Placement
## 2. Mechanical Feasibility
  ### 2.1 Wall Stiffness
  ### 2.2 Split-Plane Joint Integrity
  ### 2.3 Bolt Pattern and Counterbore Landing
  ### 2.4 Pillar Dimensions
  ### 2.5 Crossover Mounting Bosses
  ### 2.6 Interlock Boss/Recess Configuration
  ### 2.7 Heat-Set Insert Engagement
## 3. Dimensional Verification
## 4. Advantages Over Original Design
## 5. Potential Risks and Mitigations
## 6. STL Geometry Verification
## 7. FDM Printability
## 8. Component Envelope Validation
## 9. Summary
```

**What to update after a design change:**
1. **Volume numbers** (§1.1) — if depth, width, or height changed
2. **Port tuning** (§1.2) — if port parameters or volume changed
3. **Baffle diffraction** (§1.3) — if baffle width or roundover changed
4. **Dimensional verification** (§3) — recalculate affected clearances
5. **Validation status** (§8.3) — update pass/fail counts if assertions changed
6. **Summary** (§9) — update the overall status paragraph

## Change-to-Section Mapping

Use this table to determine which sections need updating for a given change:

| Change Type | claude.md | README.md | analysis.md |
|---|---|---|---|
| Depth changed | Session + Params | Specs table | §1.1 Volume, §1.6 Port, §3.x Clearances |
| Width/height changed | Session + Params | Specs table | §1.1 Volume, §1.3 Diffraction, §3.x |
| Roundover changed | Session + Params | Design Features | §1.3 Diffraction, §7 Printability |
| Port moved/resized | Session + Params | Specs table | §1.2 Tuning, §1.6 Placement, §3.3 |
| Crossover repositioned | Session + Params | — | §2.5, §3.x, §8 Validation |
| New internal feature | Session + Notes | Design Features | New subsection in §2 or §3 |
| Hardware change | Session + Params | BOM, Assembly | §2.7 Insert Engagement |
| Validation status change | Session | Validating section | §8.3 Status |
| Print orientation change | Session + Notes | Print Settings | §7 Printability |

## Git Commit Workflow

After updating all docs:

1. **Explain changes to the user first** — always describe what's being committed before staging
2. **Stage and commit** with a clear short summary:
   ```bash
   git add speedster-ai.scad component-envelopes.scad claude.md README.md analysis.md models/ renders/
   git commit -m "feat: [concise description of change]

   [Optional body with details]

   Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
   ```
3. Use conventional commit prefixes: `feat:` for new features, `fix:` for corrections, `docs:` for doc-only changes, `refactor:` for restructuring

## Tips

- When updating volume numbers, use the values from `./validate.sh` output (the ECHO lines), not manual calculations
- The README specs table and analysis.md §1.1 must show the same volume numbers
- The claude.md locked parameters table is the single source of truth for current values
- Keep Design Session entries in claude.md factual and concise — future agents need to scan these quickly
- If a session resolves an Open Item, move it from the list and note it in the session entry
