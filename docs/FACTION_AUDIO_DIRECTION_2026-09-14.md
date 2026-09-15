# Faction audio directions — 2026-09-14

Status: OWNER-IMPORTED SOUNDCLOUD/MENU TRACKS WILL ALSO SUPPLY FACTION MUSIC. GENERATED COMPOSITION PASS STOPPED. Shared catalogue and faction assignments pending.

Initial request was the direction list below. Brandon subsequently authorized all 18 previews: “Go for it. I wanna hear them all before approving.” Eighteen original sampled-instrument/synthesis sketches are now produced and saved. Existing faction vocals/gibberish remain parked. No new runtime audio is installed.

## Verified inventory

Live HEAD 96019224ba2633fc852682b3ce733debff916f97. Current faction_units.json contains 23 playable faction entries. Installed themed sources are Mercer/Harold apartment_beat, Stateline raiders_radio, Whittaker whittaker_radio, NBPD police_siren and TRC trc_siren. Orlov appears in Harold tests but has no dedicated theme. Thus 18 factions require a new distinct identity below. Shared engines, weapons and city ambience do not count as faction themes. Parked vocal archives do not count as active audio.

Exact integration gap: Mercer music is presently location-based; Whittaker porch music and TRC siren are gated to the estate, NBPD sirens to the bridge; Stateline radio is faction-selected. Existing assets therefore do not yet constitute uniform faction audio coverage on every map. Retain the accepted sounds and repair those bindings when doing the eventual faction-wide integration. Siren-only identities count as intentional audio identities; do not invent music for NBPD/TRC from this proposal.

## Historical genre proposals — audition01 rejected

| Faction | Proposed vibe |
| --- | --- |
| Eastex 44’s | Houston-style hip-hop: slow, heavy bass, hazy keys and a relaxed, confident bounce. |
| Calle Ocho | Chicano rap and lowrider funk: rubbery bass, warm guitar and a laid-back street groove. |
| Ventresca Family | Vintage Italian lounge: muted trumpet, warm organ and a small jazz rhythm section; familiar but ominous. |
| Ravicci Family | Elegant Italian noir: piano, low strings and a restrained waltz; wealthy, composed and threatening. |
| Orlov Bratva | Cold post-punk: driving bass, stark guitar and rigid drums; brooding, tough and unsentimental. |
| Zangyaku | Underground breakbeat and industrial rock: sharp guitar, distorted bass and tight percussion; fast and precise. |
| Bìtiān | Hong Kong crime-cinema trip-hop: smoky electric piano, deep bass and sparse plucked strings; sleek and nocturnal. |
| Cártel de Sierra Roja | Dark instrumental corridos: picked guitars, low brass and a deliberate, swaggering rhythm. |
| McAllister Holdings, Inc. | Country-club jazz and blues: clean guitar, piano and brushed drums; polished, smug and unhurried. |
| Mercer 44’s | A fuller Southern hip-hop sound: Mercer’s grit with Eastex’s bass and bounce; triumphant and imposing. |
| Whittaker–McAllister Corporation | Southern blues-rock with polished keys and drums: rural grit backed by serious money. |
| La Unión del Sur | Latin street beats with corrido guitar and brass: heavy percussion, thick bass and a commanding groove. |
| L’Ordine di Lombardia | Grand orchestral crime music: dark strings, brass and a strong bass groove; power and ceremony. |
| Raiders of the Sand | Scrapyard horror: detuned guitar, rattling metal and damaged tape loops; filthy, unstable and unsettling. |
| Majmu’at al-Saffar | Arabic downtempo: oud or qanun phrases, hand percussion and deep bass; poised and quietly menacing. |
| The Kurgan Group | Militaristic industrial: measured heavy drums, metallic rhythms and low brass; disciplined and relentless. |
| The Ashford-Crane Collective | Warped ballroom music: waltz piano, chamber strings and subtle tape warble; elegance that feels wrong. |
| Blacktop Apostles MC | Crushing doom/sludge metal: down-tuned guitars, lumbering live drums and feedback; grim and fanatical. |

## Presentation intent and next step

Extend the established spatial vehicle/property-source approach, with music low during combat and appropriate winner emphasis, subject to owner direction. Use convincing instruments/recorded textures; no commitment to a particular provider or a proven generation capability is made by these descriptions. These are musical direction proposals, not new faction lore. Preserve all current audio and the parked-vocals decision.

Next: incorporate owner feedback on this list, then plan sample production and shared faction bindings. No gameplay edits or audio validation were needed for this documentation-only pass. Sources inspected: gameplay/tactical_convoy_audio.gd, gameplay/tactical_battle_audio.gd, assets/audio, assets/data/faction_units.json, current hive/journal, docs/AUDIO_CINEMATICS_2026-09-10.md and faction unit-design records. Runtime source is authoritative for current bindings; dated outfit-production notes are historical. One read command hit Windows cp1252 output encoding; rerun with UTF-8 succeeded.


## Audition 01 handoff

All 18 directions now have labeled listening previews, pending owner approval. See ../tools/faction_audio_preview_20260914/README.md, review_index.json, validation.json and delivery_receipt.json for exact files, checks and limits. Historical next-step text above is superseded: owner listening review is now next. No independent artistic/listening approval or in-game loop/transition validation claimed.


## Current owner-directed mood and dark rebuild 02

All first-pass samples rejected: too happy, upbeat, fast, fun and good-energy. DEAD STREET needs bad vibes, dark energy and hard music in every faction. Faction identity does not override that shared mood. All 18 have new compositions at 80% of prior BPM; full-score changes, not slowed old recordings. V2 remains pending owner listening approval.

| Faction | Rebuild direction | BPM |
|---|---|---|
| Eastex 44’s | Cold Houston menace · blown-out sub · haunted keys | 64.0 |
| Calle Ocho | After-midnight lowrider threat · dirty guitar · deep bass | 70.4 |
| Ventresca Family | Back-room intimidation · wounded trumpet · black organ | 78.4 |
| Ravicci Family | Funeral procession · low piano · suffocating strings | 72.0 |
| Orlov Bratva | Concrete brutality · cold bass ostinato · corroded guitar | 102.4 |
| Zangyaku | Half-time industrial violence · jagged cuts · sub impact | 113.6 |
| Bìtiān | Rain-black crime scene · hollow keys · crushing trip-hop | 65.6 |
| Cártel de Sierra Roja | Execution corrido · low picked strings · threatening brass | 83.2 |
| McAllister Holdings, Inc. | Old-money cruelty · baritone blues · cold piano | 80.0 |
| Mercer 44’s | Hostile Southern weight · distorted 808 · black brass | 68.8 |
| Whittaker–McAllister Corporation | Oil-black Southern sludge · corrupt power · slow violence | 81.6 |
| La Unión del Sur | Cartel street menace · heavy percussion · threatening strings | 75.2 |
| L’Ordine di Lombardia | Imperial dread · crushing brass · fatal strings | 67.2 |
| Raiders of the Sand | Rust, violence and rot · broken metal · detuned grime | 60.8 |
| Majmu’at al-Saffar | Desert-night dread · low plucked strings · merciless drums | 72.0 |
| The Kurgan Group | Mechanized brutality · steel impacts · low marching weight | 76.8 |
| The Ashford-Crane Collective | Rotten aristocracy · decaying piano · chamber horror | 76.8 |
| Blacktop Apostles MC | Punishing funeral doom · filthy low guitars · absolute weight | 54.4 |

Current evidence/receipts: ../tools/faction_audio_preview_20260914/rebuild02/. No game installation or independent artistic validation. Next: owner hears all 18 remakes. This supersedes all older next-step and acceptance-pending descriptions of audition01.


## Musical distinction correction / contrast03

Owner reports all rebuild02 tracks sound like the same melody or sequence. Verified source had a common bass movement and recurring backbeat/lead gestures; changing instruments and individual note arrays was insufficient. Musical identity requires individually composed rhythm, bass, harmony, phrases and form. Three concrete tests are saved in ../tools/faction_audio_preview_20260914/contrast03/: Eastex rap, Ravicci chamber without drums, Blacktop guitar-led doom. Owner listens before expanding to other 15. All three unapproved, no game installation. This supersedes the all-18-v2 review plan.


## Current expansion / individual04

Owner likes the three contrasting pieces and authorized extending that direction to all remaining factions, heavily considering background and description. Preserve those three exact audio files. Individually compose the other 15; prepare a full 18-track audition. No new runtime audio or vocals. See journal 20260914-faction-audio-individual-01. Prior instruction to wait before expanding is superseded.


## 20260914-faction-audio-individual-03 — full 18-track audition saved

Fifteen new individually authored faction compositions complete, grounded in live glossary and original faction sheets; three liked contrast03 recordings preserved byte-for-byte. Source, full score manifest, background brief and evidence saved in tools/faction_audio_preview_20260914/individual04. The 489.773-second review reel has 18 labeled chapters; embedded player and all 18 MP3s saved. See delivery_receipt.json for 20 durable IDs/hashes. Reel libfile_3589763548ec8191ba3c6c0c6623d25a; player libfile_62828c5e369c81918244e67ee781b80d.

Validation: all 18 WAV format/duration checks, MP3 hash/full-decode/levels, complete faction coverage, score-event range checks and six exact anchor audio comparisons pass. MP3 loudness -18.48 to -18.26 LUFS; worst true peak -2.63 dBTP. Reel full decode and 18 chapters pass; all title cards visually inspected. No independent listening verdict, browser-interaction test, game mixing or loop/transition validation claimed. Technical uniqueness checks do not prove perceived distinction.

Owner direction approval is recorded; the fifteen new previews remain unheard/unapproved. No runtime/UI changes or vocals. Preserve five existing audio identities and all concurrent work. Source/evidence checkpoint only; no commit/push attempted in this pass. Next: owner listening feedback by faction, then approved production-loop and shared-binding work. This supersedes remaining-15-pending and contrast03-review-first next steps.


## 20260914-faction-audio-rhythm-01 — owner rejects rhythm; Bìtiān direction rejected

Owner feedback: “im trying to just accept it and say ok but like why is everything off beat like crazy...are you able to understand what on beat music sounds like?” Follow-up: “also bitian nocturnal trip hop is just not it at all”. Individual04 is not accepted; do not interpret the owner's earlier praise for contrast03 direction as approval of the full set. Bìtiān's nocturnal trip-hop concept is rejected, not merely its timing. No replacement Bìtiān genre has been approved.

Source diagnosis: authored beat locations vary inconsistently across instruments. Calle Ocho's nominal backbeats are displaced by 0.08–0.16 beats (roughly 68–136 ms at 70.4 BPM), while kick/bass/guitar use unrelated fractional placements. Several other scores deliberately use irregular offsets and unusual meters. Unusual meters and syncopation are not inherently wrong; the implementation lacked a reliable common rhythmic foundation. These authored placements, not the renderer's small +/-3 ms humanization, are the primary identified timing defect. Cannot establish every perceived issue from score alone.

Assistant acknowledged overcorrecting sameness with rhythmic irregularity and failing to establish groove. Prior decode/loudness/hash checks proved file integrity, not musical quality. No independent listening validation occurred; be candid about inability to reliably audition rendered music by ear in this workflow. Owner should not need to accept a result they dislike.

Next: rebuild the rhythmic foundation around a clear repeatable pulse, coherent kick/bass/backbeat relationships and deliberate subdivisions; validate a small concrete groove before another full-faction render. Distinction should come from composition, instruments, sound and arrangement, not arbitrary timing. Bìtiān needs a new musical concept informed by further owner direction/reference, not polishing the rejected trip-hop track. Preserve all earlier media as failed/reference evidence. No new render, runtime edits or Git publication in this diagnostic block.

Fresh remote HEAD ca7688947ef3ae67bdb136359c43666fe4d99e70. Audio source folder and topic remain untracked. Another work scope has staged shared records and music-controls files; preserve that index exactly and append/merge our working documentation only. No staging/unstaging/commit/push performed.


## 20260914-faction-audio-shared-music-01 — owner chooses imported soundtrack for dual use

Owner: “i think i have a better idea. all the soundcloud beats i import and make menu music will be used for the faction audio. great dual use”. ACCEPTED PRODUCT DIRECTION: owner-imported SoundCloud/menu tracks will also supply faction music. Stop the separately generated faction-composition pass. This supersedes rhythm-01's next step to make another programmed groove and the pending individual04 approval plan. Preserve prior previews and failure records as historical evidence; no new generated faction tracks or vocals.

Verified current source: gameplay/sandbox_menu_music.gd currently loads a single asset, res://assets/menu/opening/B-22_Dead_Street.mp3. There is no implemented shared catalogue or faction-track mapping in that script. Native menu music pauses when sandbox UI is hidden. Current hive music-import-readiness-01 assigns incoming SoundCloud URL intake / queue implementation to chat3ca0ac6a33c3; preserve its scope and opening/portrait ownership. Fresh repository HEAD ec7a60edaaa7d25493bdae523a6ab44d42148391; index empty before this documentation block.

Implementation direction: import a track once with source title/artist provenance, use its shared asset identity in the menu playlist and faction music associations. Keep faction assignments separate from menu shuffle state. Existing spatial vehicle/property playback and restrained combat mix remain applicable. This is a proposed implementation structure for the owner's approved dual-use concept, not a claim it has been built. Preserve accepted nonmusic engines/sirens/weapons and the parked-vocals rule. No immediate replacement of existing installed faction sounds or arbitrary assignment of the sole signature track.

Exact remaining gaps: additional imported tracks, owner-selected/accepted faction associations, shared catalogue and battle integration. No new URLs or specific faction associations supplied in this message. Next: continue established import workflow, then assign suitable imported tracks to factions and implement/validate shared-asset playback and combat ducking. This does not require resuming generated Bìtiān music. Discussion/coordination only: no runtime/media edit, import, commit or push; documentation saved and verified.
