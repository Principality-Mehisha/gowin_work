"""Compare the complete RTL output frame with the independent reference."""
from pathlib import Path
import numpy as np
from PIL import Image

root=Path(__file__).resolve().parents[1]/'output/video_integration'
actual=np.array(Image.open(root/'waterfall_rtl.ppm'))
expected=np.array(Image.open(root/'reference.png'))
assert actual.shape==expected.shape==(900,1600,3)
if not np.array_equal(actual,expected):
    where=np.argwhere(np.any(actual!=expected,axis=-1))
    raise AssertionError(f'{len(where)} differing pixels, first (y,x)={where[0]}')
Image.fromarray(actual).save(root/'piano_hdmi_preview.png')
print('PASS: all 1,440,000 RTL pixels match the independent reference')
