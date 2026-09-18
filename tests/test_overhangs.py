# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Todd Sayre

import io
import math
import struct
import sys
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from unittest.mock import patch

# The scripts are plain files rather than a package, so put them on the path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

import overhangs  # noqa: E402


ZEROED_NORMAL = (0.0, 0.0, 0.0)  # The spec allows it, so scan must not read it


# A triangle whose face hangs the given angle past vertical, wound to the STL
# right-hand rule so its computed normal points down and out
def hanging_facet(angle):
    tilt = math.radians(angle)
    return (
        ZEROED_NORMAL,
        [(0, 0, 1), (1, 0, 1), (0, -math.sin(tilt), 1 - math.cos(tilt))],
    )


# Corners of a closed tetrahedron, wound so every edge is used once in each
# direction. The closure tests below break the same mesh in one place at a time
CORNERS = {
    "a": (0.0, 0.0, 0.0),
    "b": (1.0, 0.0, 0.0),
    "c": (0.0, 1.0, 0.0),
    "d": (0.0, 0.0, 1.0),
}


def facet(*names):
    return (ZEROED_NORMAL, [CORNERS[name] for name in names])


TETRAHEDRON = [
    facet("a", "c", "b"),
    facet("a", "b", "d"),
    facet("b", "c", "d"),
    facet("a", "d", "c"),
]


def write_stl(path, facets):
    """Write facets out as a binary STL, the way OpenSCAD exports one

    A facet record is 50 bytes: a normal, three vertices, and the attribute
    count that nothing reads
    """
    with path.open("wb") as stream:
        stream.write(b"\0" * 80)
        stream.write(struct.pack("<I", len(facets)))
        for normal, vertices in facets:
            values = [*normal, *vertices[0], *vertices[1], *vertices[2]]
            stream.write(struct.pack("<12fH", *values, 0))


class ScanTests(unittest.TestCase):
    def test_flags_angle_that_rounds_down_to_limit(self):
        angle = 45.04
        facets = [hanging_facet(angle)]

        with patch.object(overhangs, "read_facets", return_value=iter(facets)):
            _, groups = overhangs.scan("synthetic.stl")

        self.assertAlmostEqual(groups[0][0], angle)
        self.assertEqual(overhangs.past_limit(groups), groups)

    def test_ignores_degenerate_facet_whatever_its_stored_normal_says(self):
        ceiling_normal = (0.0, 0.0, -1.0)
        collinear = [(0, 0, 1), (1, 0, 1), (2, 0, 1)]
        facets = [(ceiling_normal, collinear)]

        with patch.object(overhangs, "read_facets", return_value=iter(facets)):
            total, groups = overhangs.scan("synthetic.stl")

        self.assertEqual(total, 1)
        self.assertEqual(groups, [])


class ClosureTests(unittest.TestCase):
    def test_closed_tetrahedron_has_no_defects(self):
        closure = overhangs.closure_of(TETRAHEDRON)

        self.assertTrue(closure.closed)
        self.assertEqual(closure.open_edges, 0)
        self.assertEqual(closure.non_manifold_edges, 0)
        self.assertEqual(closure.reversed_edges, 0)
        self.assertEqual(closure.degenerate_facets, 0)
        self.assertEqual(closure.samples, ())

    def test_missing_face_leaves_its_three_edges_open(self):
        closure = overhangs.closure_of(TETRAHEDRON[:-1])

        self.assertFalse(closure.closed)
        self.assertEqual(closure.open_edges, 3)

    def test_reversed_face_reverses_each_of_its_three_edges(self):
        normal, vertices = TETRAHEDRON[0]
        reversed_face = (normal, list(reversed(vertices)))

        closure = overhangs.closure_of([reversed_face, *TETRAHEDRON[1:]])

        self.assertFalse(closure.closed)
        self.assertEqual(closure.reversed_edges, 3)
        self.assertEqual(closure.open_edges, 0)

    def test_third_facet_on_an_edge_is_non_manifold(self):
        a, b = CORNERS["a"], CORNERS["b"]
        facets = [
            (ZEROED_NORMAL, [a, b, (0.0, 0.0, 1.0)]),
            (ZEROED_NORMAL, [b, a, (0.0, 0.0, 2.0)]),
            (ZEROED_NORMAL, [a, b, (0.0, 2.0, 0.0)]),
        ]

        closure = overhangs.closure_of(facets)

        self.assertFalse(closure.closed)
        self.assertEqual(closure.non_manifold_edges, 1)
        self.assertEqual(closure.open_edges, 6)

    def test_degenerate_facet_is_counted_and_uses_up_no_edge(self):
        # Its long edge is the real facet's, and the facet itself doubles back
        # along it: counting that would leave the edge looking shared when
        # nothing is on its other side
        real = (ZEROED_NORMAL, [CORNERS["a"], CORNERS["b"], (0.0, 2.0, 0.0)])

        closure = overhangs.closure_of([real, facet("a", "b", "b")])

        self.assertEqual(closure.degenerate_facets, 1)
        self.assertEqual(closure.open_edges, 3)

    def test_samples_stop_at_the_cap(self):
        # Facets that touch nothing, so every edge of every one of them is open
        facets = [
            (
                ZEROED_NORMAL,
                [(float(i), 0, 0), (float(i + 1), 0, 0), (float(i), 1, 0)],
            )
            for i in range(overhangs.SAMPLES + 3)
        ]

        closure = overhangs.closure_of(facets)

        self.assertGreater(closure.open_edges, overhangs.SAMPLES)
        self.assertEqual(len(closure.samples), overhangs.SAMPLES)


class ReportTests(unittest.TestCase):
    def test_exit_code_follows_the_closure_verdict(self):
        with tempfile.TemporaryDirectory() as directory:
            intact = Path(directory) / "intact.stl"
            holed = Path(directory) / "holed.stl"
            write_stl(intact, TETRAHEDRON)
            write_stl(holed, TETRAHEDRON[:-1])

            with redirect_stdout(io.StringIO()):
                intact_code = overhangs.report(intact)
                holed_code = overhangs.report(holed)

        self.assertEqual(intact_code, 0)
        self.assertEqual(holed_code, 1)


if __name__ == "__main__":
    unittest.main()
