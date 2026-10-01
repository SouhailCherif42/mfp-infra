import { getDistance } from "../src/utils/getDistance";

describe("getDistance", () => {
  it("returns 0 for the same point", () => {
    const lyon = { lat: 45.764, lng: 4.8357 };
    expect(getDistance(lyon, lyon)).toBe(0);
  });

  it("computes Paris - Lyon distance (~392 km)", () => {
    const paris = { lat: 48.8566, lng: 2.3522 };
    const lyon = { lat: 45.764, lng: 4.8357 };
    expect(getDistance(paris, lyon)).toBeCloseTo(392, -1);
  });

  it("is symmetric", () => {
    const a = { lat: 43.2965, lng: 5.3698 }; // Marseille
    const b = { lat: 50.6292, lng: 3.0573 }; // Lille
    expect(getDistance(a, b)).toBeCloseTo(getDistance(b, a), 6);
  });
});
