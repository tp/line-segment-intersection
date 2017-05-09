
/*:
 
 Ported from http://geomalgorithms.com/a05-_intersect-1.html
 Original C++ implementation Copyright 2001 softSurfer, 2012 Dan Sunday
 */

let SMALL_NUM: Double = 1 / 10000;

struct Point2D {
    let x: Double
    let y: Double
}

struct LineSegment {
    let p0: Point2D
    let p1: Point2D
}

func dot(_ u: Point2D, _ v: Point2D) -> Double {
    return u.x * v.x + u.y + v.y
}

func perp(_ u: Point2D, _ v: Point2D) -> Double {
    return u.x * v.y - u.y * v.x
}

enum IntersectResult {
    case Disjoint // no intersec
    case Intersect(p: Point2D)
    case Overlap(lineSegment: LineSegment)
}

// TODO: Make operator or extension method
func subPoints(a: Point2D, b: Point2D) -> Point2D {
    return Point2D(x: a.x - b.x, y: a.y - b.y)
}

func inSegment(_ P: Point2D, _ S: LineSegment) -> Bool {
    if (S.p0.x != S.p1.x) {    // S is not  vertical
        if (S.p0.x <= P.x && P.x <= S.p1.x) {
            return true;
        }
        
        if (S.p0.x >= P.x && P.x >= S.p1.x) {
            return true
        }
    } else {    // S is vertical, so test y  coordinate
        if (S.p0.y <= P.y && P.y <= S.p1.y) {
            return true
        }
        if (S.p0.y >= P.y && P.y >= S.p1.y) {
            return true
        }
    }
    
    return false
}

func intersect2DSegments(_ s1: LineSegment, _ s2: LineSegment) -> IntersectResult {
    let u = subPoints(a: s1.p1, b: s1.p0)
    let v = subPoints(a: s2.p1, b: s2.p0)
    let w = subPoints(a: s1.p0, b: s2.p0)
    let D = perp(u, v)
    
    if (abs(D) < SMALL_NUM) {
        if (perp(u,w) != 0 || perp(v,w) != 0)  {
            return .Disjoint;                    // they are NOT collinear
        }
        // they are collinear or degenerate
        // check if they are degenerate  points
        let du = dot(u,u);
        let dv = dot(v,v);
        if (du==0 && dv==0) {            // both segments are points
            if (s1.p0.x !=  s2.p0.x && s1.p0.y !=  s2.p0.y) {
                return .Disjoint
            }

            return .Intersect(p: s1.p0);  // they are the same point
        }
        if (du==0) {                     // S1 is a single point
            if  (inSegment(s1.p0, s2) == false) { // but is not in S2
                return .Disjoint
            }

            return .Intersect(p: s1.p0);
        }
        if (dv==0) {                     // S2 a single point
            if  (inSegment(s2.p0, s1) == false) { // but is not in S1
                return .Disjoint;
            }

            return .Intersect(p: s2.p0);
        }
        // they are collinear segments - get  overlap (or not)
        var t0: Double = 0
        var t1: Double = 0;                    // endpoints of S1 in eqn for S2
        let w2 = subPoints(a: s1.p1, b: s2.p0);
        if (v.x != 0) {
            t0 = w.x / v.x;
            t1 = w2.x / v.x;
        }
        else {
            t0 = w.y / v.y;
            t1 = w2.y / v.y;
        }
        if (t0 > t1) {                   // must have t0 smaller than t1
            let t=t0;
            t0=t1;
            t1=t;    // swap if not
        }
        if (t0 > 1 || t1 < 0) {
            return .Disjoint;      // NO overlap
        }
        t0 = t0 < 0 ? 0 : t0;               // clip to min 0
        t1 = t1 > 1 ? 1 : t1;               // clip to max 1
        if (t0 == t1) {                  // intersect is a point
            let vByT0 = Point2D(x: v.x * t0, y: v.y * t0)
            
            return .Intersect(p: Point2D(x: s2.p0.x + vByT0.x, y: s2.p0.y + vByT0.y));
        }
        
        let vByT0 = Point2D(x: v.x * t0, y: v.y * t0)
        let vByT1 = Point2D(x: v.x * t1, y: v.y * t1)
        
        let a = Point2D(x: s2.p0.x + vByT0.x, y: s2.p0.y + vByT0.y);
        let b = Point2D(x: s2.p0.x + vByT1.x, y: s2.p0.y + vByT1.y)
        
        let segment = LineSegment(p0: a, p1: b)
        
        return .Overlap(lineSegment: segment);
    } else {

        let sI = perp(v ,w) / D;
        if (sI < 0 || sI > 1) {
            return .Disjoint;
        }
        
        // get the intersect parameter for S2
        let tI = perp(u,w) / D;
        if (tI < 0 || tI > 1) {
            return .Disjoint
        }
        
        // original: *I0 = S1.P0 + sI * u;
        let uBySi = Point2D(x: u.x * sI, y: u.y * sI)
        let i0 = Point2D(x: s1.p0.x + uBySi.x, y: s1.p0.y + uBySi.y);

        return .Intersect(p: i0);
    }
}

let segOnXAxis = LineSegment(p0: Point2D(x: -5, y: 0), p1: Point2D(x: 5, y: 0))
let segOnYAxis = LineSegment(p0: Point2D(x: 0, y: -5), p1: Point2D(x: 0, y: 5))
let segXAxisParallel = LineSegment(p0: Point2D(x: -5, y: 1), p1: Point2D(x: 5, y: 1))

dump(intersect2DSegments(segOnXAxis, segOnXAxis))
dump(intersect2DSegments(segOnYAxis, segOnYAxis))
dump(intersect2DSegments(segOnXAxis, segOnYAxis))
dump(intersect2DSegments(segOnXAxis, segXAxisParallel))
