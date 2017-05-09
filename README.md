# Line Segment Intersection

A line segment intersection algorithm, implemented in Swift.

## Result Type

```swift
enum IntersectResult {
    case Disjoint // no intersection
    case Intersection(point: Point2D)
    case Overlap(lineSegment: LineSegment)
}
```