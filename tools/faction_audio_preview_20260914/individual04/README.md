# DEAD STREET — Individual faction audio 04

Status: FULL AUDITION READY; OWNER LISTENING REVIEW PENDING. Contrast03 direction was liked, and owner authorized its application to remaining factions while heavily considering background and description. This set contains 15 newly authored scores plus three byte-identical contrast03 anchors: Eastex, Ravicci and Blacktop. No new game audio, vocals, gameplay or UI changes.

## Creative handoff

Read BRIEF.md for faction-specific source facts and musical interpretations. Live faction_glossary.json plus original Major Gangs and Authorities / Possible Merged Factions sheets informed the score. Public glossary omits some campaign spoilers; original reference provides merger and invading-faction history. No inferred music choice is new faction lore.

Audition01 was rejected for happy/upbeat energy. Rebuild02 was rejected for the common melody/sequence. Keep those failures as references; do not reuse their shared bass or backing generators. Each new song owns its note events, rhythm, harmony and form. Generic rendering/instrument helpers are shared. These are short original instrumental sketches for approval, not finished looping production assets.

## Files and verification

- review_index.json: order, descriptions, timing and master/MP3 hashes.
- manifest.json: complete score events and origin per faction.
- preserved_anchors.json: all six original/copy WAV and MP3 hashes; exact matches.
- score_checks.json: 18-faction coverage, event ranges, exact-score duplication guard.
- validation.json: all 18 WAV headers/rates/channels/durations and MP3 hashes verified; full MP3/reel decode, 18 chapters, loudness/true peak gates.
- delivery_receipt.json: durable review video, embedded HTML playlist and 18 MP3 identities.

The reel is 489.773 seconds. MP3 integrated loudness ranges from -18.48 to -18.26 LUFS; maximum true peak is -2.63 dBTP. All 18 title cards were visually inspected. No independent listening verdict, browser interaction test, runtime mix/ducking test or production loop/transition validation is claimed. Technical checks cannot establish artistic distinction or acceptance.

## Reproduction

Python 3.12, numpy 2.3.5, scipy 1.17.0, Pillow 12.3.0, tinysoundfont 0.3.7 and FFmpeg. Sample bank: ../dependencies/GeneralUser-GS.sf2 (2.0.3), SHA256 9575028c7a1f589f5770fccc8cff2734566af40cd26ed836944e9a5152688cfe. See ../fetch_instruments.py and GeneralUser_LICENSE.txt. Rendered sample-based instruments plus original synthesized bass, guitar and percussion; no recorded performances or external music generator claimed.

Run `python compose_individuals.py`, then `python package_review.py` from this folder. The first renders new15 and copies the exact existing contrast03 files; if that folder's original WAVs are absent, recover previous artifacts/re-render contrast03 with its recorded environment first and verify hashes. Atomic output staging is retained from contrast03. Masters/media are durable via delivery receipt rather than added to the game repository.

## Ownership and next step

Verified starting branch build/arsenal-checkpoint-20260911 at ca7688947ef3ae67bdb136359c43666fe4d99e70. Audio scope: this folder and scoped audio records; preserve concurrent opening/menu/glossary, character and gameplay work. Existing five audio identities and the accepted estate battle remain untouched. Source/evidence saved on development PC; no commit/push in this pass. Earlier automatic review blocked source publication; no retry made.

Next: owner hears all 18, identifies per-faction revisions or approvals. Then finish approved tracks/loops and faction-wide bindings, preserving combat ducking and five existing identities. Direction approval is not blanket approval of these unheard previews.

| # | Faction | Reel start | Origin |
|---|---|---|---|
| 01 | Eastex 44’s | 0:00 | contrast03 byte-identical anchor |
| 02 | Calle Ocho | 0:24 | individual04 new composition |
| 03 | Ventresca Family | 0:50 | individual04 new composition |
| 04 | Ravicci Family | 1:15 | contrast03 byte-identical anchor |
| 05 | Orlov Bratva | 1:42 | individual04 new composition |
| 06 | Zangyaku | 2:12 | individual04 new composition |
| 07 | Bìtiān | 2:43 | individual04 new composition |
| 08 | Cártel de Sierra Roja | 3:10 | individual04 new composition |
| 09 | McAllister Holdings, Inc. | 3:38 | individual04 new composition |
| 10 | Mercer 44’s | 4:04 | individual04 new composition |
| 11 | Whittaker–McAllister Corporation | 4:30 | individual04 new composition |
| 12 | La Unión del Sur | 4:59 | individual04 new composition |
| 13 | L’Ordine di Lombardia | 5:26 | individual04 new composition |
| 14 | Raiders of the Sand | 5:55 | individual04 new composition |
| 15 | Majmu’at al-Saffar | 6:20 | individual04 new composition |
| 16 | The Kurgan Group | 6:45 | individual04 new composition |
| 17 | The Ashford-Crane Collective | 7:12 | individual04 new composition |
| 18 | Blacktop Apostles MC | 7:41 | contrast03 byte-identical anchor |
