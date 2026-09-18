#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Todd Sayre
"""Report what an exported STL will do on a printer.

Two questions, both read off one pass over the facets: what overhangs, and
whether the mesh is a closed solid.

Overhang angle is measured from vertical: a vertical wall is 0 deg, a flat
ceiling is 90 deg, and the usual unsupported limit is 45 deg. Facets lying on
the build plate are ignored, since the first layer is not an overhang.

A closed mesh is one whose every edge is shared by exactly two facets, wound
opposite ways. That is what a slicer needs to tell which side of a wall is
solid, and it is what OpenSCAD's `manifold` status line stands in for — reading
it off the mesh means a part that exports as a `PolySet`, and so prints no
status line at all, is checked the same as any other.

Used as a library by build.py, which warns on what this finds without failing
the build.
"""

import math
import struct
import sys
from dataclasses import dataclass
from pathlib import Path

LIMIT = 45.0  # Degrees from vertical, the usual unsupported limit

PLATE = 1e-3  # Height below which a downward facet is just the first layer

# Degrees of grace for float32 vertex rounding. Normals are computed from the
# stored vertices, which land an exact 45 deg chamfer within microdegrees of
# the limit and an exact vertical wall within millidegrees of hanging, so both
# need slack — and a real design overhang is whole degrees past it
SLACK = 0.01

# Offending edges a closure report names before it stops pointing at them
SAMPLES = 5


class MeshError(RuntimeError):
    pass


@dataclass(frozen=True)
class Closure:
    """How a mesh's edges add up, which is what makes it a solid.

    Every edge of a closed surface is shared by exactly two facets, and those
two traverse it in opposite directions. A single use is an open boundary, so
the surface has a hole there; three or more is a non-manifold edge, where
surfaces meet along a line; two uses in the same direction is a pair of facets
that disagree about which side is outside, so one of them is inverted.

    All three counts are edges. Facets with no area are left out of them: one
closes nothing, and an STL writes the same vertex twice for it, so counting it
would add a use to each side of an edge and turn a hole into a junction. The
count is still reported, because a mesh carrying them came out of a boolean that
padded a seam rather than merging it.
    """

    open_edges: int
    non_manifold_edges: int
    reversed_edges: int
    degenerate_facets: int
    samples: tuple  # (kind, edge, uses) for the first SAMPLES offenders

    @property
    def closed(self):
        return not (self.open_edges or self.non_manifold_edges or self.reversed_edges)


def read_facets(path):
    data = Path(path).read_bytes()
    if len(data) < 84:
        raise MeshError(f"{path}: too short to be a binary STL")
    count = struct.unpack("<I", data[80:84])[0]
    if len(data) < 84 + 50 * count:
        raise MeshError(f"{path}: not a binary STL, or truncated")
    for i in range(count):
        offset = 84 + 50 * i
        normal = struct.unpack("<3f", data[offset : offset + 12])
        vertices = [
            struct.unpack("<3f", data[offset + 12 + 12 * j : offset + 24 + 12 * j])
            for j in range(3)
        ]
        yield normal, vertices


def facet_nz(a, b, c):
    """Unit-normal z of a facet, from its vertices under the STL right-hand
    rule. The stored normal is deliberately not used: the spec lets it be
    zeroed and nothing keeps it unit length, and either would let a hanging
    face pass as vertical. Returns None for a degenerate facet, which has no
    area to hang
    """
    ux, uy, uz = (b[0] - a[0], b[1] - a[1], b[2] - a[2])
    vx, vy, vz = (c[0] - a[0], c[1] - a[1], c[2] - a[2])
    nx = uy * vz - uz * vy
    ny = uz * vx - ux * vz
    nz = ux * vy - uy * vx
    length = math.sqrt(nx * nx + ny * ny + nz * nz)
    if length == 0:
        return None
    return nz / length


def scan(path):
    """group_facets, read from a file rather than handed in"""
    return group_facets(list(read_facets(path)))


def group_facets(facets):
    """Group facets by overhang angle and height.

    Returns (total facets, groups), each group a (angle, z_min, z_max, count)
    tuple sorted shallowest first
    """
    groups = {}
    total = 0

    for _, vertices in facets:
        total += 1
        nz = facet_nz(*vertices)
        if nz is None:  # Degenerate, so nothing to hang
            continue
        if nz >= 0:  # Facing upward, never an overhang
            continue
        heights = [vertex[2] for vertex in vertices]
        if max(heights) <= PLATE:  # Sitting on the plate, not hanging over anything
            continue
        angle = math.degrees(math.asin(min(1.0, -nz)))
        if angle <= SLACK:  # Vertical, within mesh precision
            continue
        key = (round(angle, 1), round(min(heights), 2), round(max(heights), 2))
        count, worst_angle = groups.get(key, (0, angle))
        groups[key] = (count + 1, max(worst_angle, angle))

    return total, [
        (worst_angle, z_min, z_max, count)
        for (_, z_min, z_max), (count, worst_angle) in sorted(groups.items())
    ]


def directed_edges(vertices):
    """A facet's three edges in its winding order, as (start, end)"""
    a, b, c = vertices
    return ((a, b), (b, c), (c, a))


def closure_of(facets):
    """Check every edge is shared by exactly two facets, wound opposite ways.

    One dict of edges, filled in one pass: each entry counts the facets using an
    edge and nets their directions, so a correctly shared edge comes out as two
    uses and no net direction. See Closure for the failing cases.

    A facet with no area is counted and then skipped. It closes nothing, and its
    doubled-back edge would otherwise look shared when it is not — see the note
    on Closure.
    """
    edges = {}
    degenerate = 0
    open_edges = 0
    non_manifold_edges = 0
    reversed_edges = 0
    samples = []

    for _, vertices in facets:
        if facet_nz(*vertices) is None:
            degenerate += 1
            continue

        for a, b in directed_edges(vertices):
            if a == b:  # A repeated vertex has no edge to be shared
                continue
            if a < b:
                key, direction = (a, b), 1
            else:
                key, direction = (b, a), -1
            uses, net = edges.get(key, (0, 0))
            edges[key] = (uses + 1, net + direction)

    for key, (uses, net) in edges.items():
        if uses == 1:
            kind = "open edge"
            open_edges += 1
        elif uses > 2:
            kind = "non-manifold edge"
            non_manifold_edges += 1
        elif net:
            kind = "reversed edge"
            reversed_edges += 1
        else:
            continue
        if len(samples) < SAMPLES:
            samples.append((kind, key, uses))

    return Closure(
        open_edges=open_edges,
        non_manifold_edges=non_manifold_edges,
        reversed_edges=reversed_edges,
        degenerate_facets=degenerate,
        samples=tuple(samples),
    )


def past_limit(groups):
    return [group for group in groups if group[0] > LIMIT + SLACK]


def describe(group):
    angle, z_min, z_max, count = group
    return (
        f"{format_angle(angle)}° from vertical, z {z_min} – {z_max} mm, {count} facets"
    )


def format_angle(angle):
    return f"{angle:.2f}".rstrip("0").rstrip(".")


def format_point(point):
    x, y, z = point
    return f"({x:g}, {y:g}, {z:g})"


def format_edge(edge):
    start, end = edge
    return f"{format_point(start)} – {format_point(end)}"


def report_closure(closure):
    """Print the closure verdict, naming a few of the edges to go and look at"""
    if closure.closed:
        print("\n  closed: every edge shared by exactly two facets, in both directions")
    else:
        print("\n  NOT closed:")
        if closure.open_edges:
            print(f"    {closure.open_edges} open edges — the surface has a hole")
        if closure.non_manifold_edges:
            print(
                f"    {closure.non_manifold_edges} non-manifold edges — "
                "surfaces meeting along a line"
            )
        if closure.reversed_edges:
            print(
                f"    {closure.reversed_edges} reversed edges — "
                "two facets sharing one and wound the same way, so one is inverted"
            )
        for kind, edge, uses in closure.samples:
            print(f"    e.g. {kind}, {format_edge(edge)}, used {uses}x")

    if closure.degenerate_facets:
        print(
            f"  {closure.degenerate_facets} degenerate facets — "
            "no area, so nothing to close"
        )


def report(path):
    facets = list(read_facets(path))
    total, groups = group_facets(facets)
    closure = closure_of(facets)
    steep = past_limit(groups)

    print(f"{path}: {total} facets, {sum(g[3] for g in groups)} of them overhanging")

    if not groups:
        print("  nothing overhangs — prints without supports in this orientation")
    else:
        print(f"  {'from vertical':>13}  {'z span (mm)':>16}  facets")
        for angle, z_min, z_max, count in groups:
            flag = "  <-- past the limit" if angle > LIMIT + SLACK else ""
            print(f"  {format_angle(angle):>12}°  {z_min:>7} – {z_max:<7}  {count}{flag}")

        worst = max(group[0] for group in groups)
        if steep:
            print(
                f"\n  worst is {format_angle(worst)}°, past the {LIMIT}° limit — redesign the feature"
            )
        else:
            print(f"\n  worst is {format_angle(worst)}°, within the {LIMIT}° limit")

    report_closure(closure)
    return 1 if steep or not closure.closed else 0


def main():
    if len(sys.argv) < 2:
        raise SystemExit("usage: overhangs.py <file.stl> [...]")
    try:
        return max(report(path) for path in sys.argv[1:])
    except (MeshError, OSError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
