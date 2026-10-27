export function hasStrongBootstrapSecret(value: string): boolean {
  return value.length >= 32;
}

export function extractBearerToken(header: string | null): string | null {
  if (!header) return null;
  const match = header.match(/^Bearer\s+(.+)$/i);
  return match?.[1] ?? null;
}

export function isExpectedBootstrapUser(actualUserId: string, expectedUserId: string): boolean {
  return expectedUserId.length > 0 && actualUserId === expectedUserId;
}

export function isBootstrapSecretBody(
  body: unknown,
): body is { bootstrapSecret: string } {
  return typeof body === "object" &&
    body !== null &&
    "bootstrapSecret" in body &&
    typeof (body as { bootstrapSecret: unknown }).bootstrapSecret === "string";
}

async function digest(value: string): Promise<Uint8Array> {
  return new Uint8Array(
    await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value)),
  );
}

/**
 * Compares fixed-size digests so the comparison loop does not exit early.
 * This is not a substitute for rate limiting or secret rotation.
 */
export async function constantTimeSecretMatch(
  supplied: string,
  expected: string,
): Promise<boolean> {
  const [left, right] = await Promise.all([digest(supplied), digest(expected)]);
  let difference = 0;
  for (let i = 0; i < left.length; i++) difference |= left[i] ^ right[i];
  return difference === 0;
}
