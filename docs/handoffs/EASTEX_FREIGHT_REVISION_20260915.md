# Eastex Freight Exchange revision - 2026-09-15


## 20260915-freight-revision-04 - Full battle delivered for owner review
IMPLEMENTED / NATIVE-VALIDATED / RECORDED. Eastex Freight Exchange now has flush timber rail crossings, worn yard connections, no painted assault parking boxes, curved/staggered arrivals and irregular diagonal stops. In-world dispatch sign, menu name, banner and refreshed thumbnail use Eastex Freight Exchange. Dense layered light-catching rain and ground/roof splashes preserve native rain sound.

424 checks at10v10 and753 at16v16 passed for the captured formation version, including sampled moving hull clearance. Full scripted10v10 capture: Ashford-Crane attacks McAllister, attacker wins after49.6 combat seconds,8 survivors. Complete88.133s1280x72030fps H264/AAC MP4 includes arrival, combat and results. No arrival/outro errors or camera violations. Audio decode passes, peak0.44565/RMS0.02811; final MP4 SHA2568a117a2f6c9f5169a35e1a83fdb70322decebe8b100be940a1ee854d9d9aea5d. Visual encoded arrival/combat/results checked.

Export concurrency guard initially stopped: bike-slots-01 changed five motorcycle/menu/bridge files during native capture. Audited in capture_concurrency_review.json; no freight source, combat runtime, weather/audio or showcase change; three enclosed vehicles and identical rehearsed result. The existing native recording was encoded after this scoped audit. New four-bike packing is NOT certified by this recording; bike pass must include current Freight placement/arrival checks, especially member3 spacing. Preserve our curves, varied facings and no-bay art while integrating any necessary bike accommodation.

Evidence/repro: tools/freight_revision_20260915/{review.gd,validation.json,capacity.json,showcase.gd,rehearsal.json,record.json,capture_worker.py,encode_verified_capture.py,capture_concurrency_review.json,delivery.json,final_scope.json,reviewed_sources.zip}. Native scene/capture uses exact legal loadouts and tactical commands, no health/damage/RNG/winner override. Existing10ObjectDB shutdown warnings retained.

Delivered DEAD_STREET_Eastex_Freight_Exchange_Battle.mp4 (libfile_11b997eb8900819180e3d0a22b8074c9; file_0000000080188230ba27f87499d09597). Handoff docs/handoffs/EASTEX_FREIGHT_REVISION_20260915.md. HEAD 35e0db12aae4d114364c911a69ae2136de30ee4e; no staging/commit/push by this pass. Natural convoy arrival direction added to MAP_BUILDING_STANDARD. Next: owner review; coordinate mixed-source publication and motorcycle packing with bike-slots pass.
