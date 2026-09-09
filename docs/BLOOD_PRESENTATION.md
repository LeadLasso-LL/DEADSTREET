# Blood presentation and future settings

Approved: small pixel hit splashes on damaging hits; localized abdomen stain beneath the wounded hand; sparse moving-wounded droplets; modest scattered ground marks at death. No large pools or continuous trail.

Future game settings must include Blood On/Off. One control must hide all four effects, including clothing stains. Current presentation switch: TacticalActorPresenter.blood_enabled. Settings-menu UI remains future work.

Blood is presentation only. It does not alter damage, wound thresholds, movement, navigation or visibility rules. Ground marks are capped at 240 and reset between battles; droplets require both distance and time so standing units do not accumulate pools.

Unit art: stronger internal contours and unbuttoned Italian jackets exposing the white shirt, preserving accepted motion and weapon grips.

Clothing stains use per-frame clothing visibility masks drawn in the same layer order as the sprites. Foreground guns, hands, arms and outlines exclude blood; Blood Off still hides all effects. Rebuild masks with export_blood_masks.py then render_blood_masks.gd whenever anatomy, clothing or equipment changes.
