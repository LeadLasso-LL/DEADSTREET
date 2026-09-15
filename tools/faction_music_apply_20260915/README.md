# Approved faction music assignments

Final: 21 factions / 21 unique loops. Owner corrected Calle Ocho to Glock — B-22; La Unión del Sur retains Burn — B-22. All other screenshot choices are retained. TRC and NBPD keep their existing sirens.

| Faction | Track | Artist |
| --- | --- | --- |
| Mercer Saints | Thunder | OB |
| Eastex 44’s | Smoke | OB |
| Calle Ocho | Glock | B-22 |
| Ventresca Family | Natural | B-22 |
| Ravicci Family | Bond | OB |
| Orlov Bratva | Ripper | B-22 |
| Zangyaku | ’97 | B-22 |
| Bìtiān | Coupe | OB |
| Stateline Raiders MC | Lurk | B-22 |
| Cártel de Sierra Roja | Break Bad | B-22 |
| Whittaker Oil & Land Co. | Keys | B-22 |
| McAllister Holdings, Inc. | Watchin’ | B-22 |
| Mercer 44’s | Block | OB |
| Whittaker-McAllister Corporation | Money Way | B-22 |
| La Unión del Sur | Burn | B-22 |
| L’Ordine di Lombardia | Jumpman | B-22 |
| Raiders of the Sand | Skyfall | B-22 |
| Majmu’at al-Saffar | Maria | OB |
| The Kurgan Group | Switch | B-22 |
| The Ashford-Crane Collective | ‘88 | B-22 |
| Blacktop Apostles MC | Dead or Alive | B-22 |

Spatial audio uses each side’s assigned loop: the Harold/estate defender building entrance, otherwise convoy transport, with a fixed-position fallback when no vehicle exists. Existing combat ducking and winning-loop continuity remain; old Harold beat is suppressed when faction music is present. Menu tracks and all audio files are unchanged.

Validation: 115 native wiring checks across Harold/bridge/estate, both sides, exact streams, 30-second wraps, winner continuity, loser background and exit stop. Both authority implementations compared against the previous source for stream data, loop limits, gain, pitch, range, attenuation, panning and metadata. Then 13 focused checks passed for the final Calle Ocho correction: 21 unique assignments, both side streams/anchors/wraps, unchanged Union Burn and authority exclusions. Historical native_validation.json covers pre-correction wiring; correction_validation.json covers the changed mapping. The first wiring declaration issue was fixed; harness result/listener warm-up issues were corrected. No subjective listening or mix-approval claim.

Final mapping: approved_assignments.json. Native sources: check_native.gd and check_correction.gd. Before-source for siren equivalence: before_tactical_convoy_audio.gd. Runtime patch and protected final hashes are retained. Picker saved choices also corrected. Publication receipt identifies actual Git status; do not infer publication from local completion.
