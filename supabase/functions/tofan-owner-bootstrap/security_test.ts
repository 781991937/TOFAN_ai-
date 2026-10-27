import {
  constantTimeSecretMatch,
  extractBearerToken,
  hasStrongBootstrapSecret,
  isBootstrapSecretBody,
} from "./security.ts";

Deno.test("bootstrap secret minimum length is enforced", () => {
  if (hasStrongBootstrapSecret("x".repeat(31))) {
    throw new Error("31-character secret must be rejected");
  }
  if (!hasStrongBootstrapSecret("x".repeat(32))) {
    throw new Error("32-character secret must be accepted");
  }
});

Deno.test("Bearer token parser accepts a valid bearer header", () => {
  if (extractBearerToken("Bearer eyJhbGciOiJIUzI1NiJ9") !== "eyJhbGciOiJIUzI1NiJ9") {
    throw new Error("valid bearer token was not extracted");
  }
  if (extractBearerToken(null) !== null || extractBearerToken("Basic abc") !== null) {
    throw new Error("invalid authorization header must be rejected");
  }
});

Deno.test("bootstrap body validation rejects malformed bodies", () => {
  if (!isBootstrapSecretBody({ bootstrapSecret: "s".repeat(32) })) {
    throw new Error("valid body was rejected");
  }
  for (const body of [null, [], {}, { bootstrapSecret: 12 }, "secret"]) {
    if (isBootstrapSecretBody(body)) {
      throw new Error("malformed body was accepted");
    }
  }
});

Deno.test("secret comparison accepts only exact matching values", async () => {
  const expected = "test-only-secret-value-that-is-long-enough";
  if (!await constantTimeSecretMatch(expected, expected)) {
    throw new Error("matching secrets should compare equal");
  }
  if (await constantTimeSecretMatch(expected, expected + "x")) {
    throw new Error("different secrets must not compare equal");
  }
  if (await constantTimeSecretMatch("wrong-secret", expected)) {
    throw new Error("wrong secret must be rejected");
  }
});
