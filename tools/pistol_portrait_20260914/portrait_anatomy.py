"""Portrait-only correction; normal animation generation is unchanged."""
from contextlib import contextmanager
import inspect
import build, outfits
_ORIGINAL = build.make
_SOURCE = inspect.getsource(_ORIGINAL)
_OLD = "sleeve_start=support_elbow*.55+support_end*.45"
assert _SOURCE.count(_OLD) == 1
_SOURCE = _SOURCE.replace(_OLD, "sleeve_start=support_elbow")
_SOURCE = _SOURCE.replace("if costume:outfits.forearm(up,sleeve_start,support_end,costume,skin,hi,2.8)",
 "if costume:outfits.forearm(up,sleeve_start,support_end,costume,skin,hi,3.1)")
_NAMESPACE = dict(build.__dict__)
exec(compile(_SOURCE, __file__, 'exec'), _NAMESPACE)
_CORRECTED = _NAMESPACE['make']

@contextmanager
def corrected(legacy_shoulders=False):
    old_make, old_arm = build.make, outfits.arm
    if legacy_shoulders:
        import eastex_outfits
        def joined(parent,a,b,h,c,skin,hi):
            # Reuse the accepted connected sleeve with the same joints/radii.
            costume=dict(c,new_unit=True,eastex=True)
            return eastex_outfits.arm(parent,a,b,h,costume,skin,hi)
        outfits.arm=joined
    build.make=_CORRECTED
    try: yield
    finally: build.make,outfits.arm=old_make,old_arm
