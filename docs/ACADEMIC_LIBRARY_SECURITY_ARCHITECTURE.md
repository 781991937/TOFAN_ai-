# TOFAN Academic Library — Security Architecture

## Purpose

The academic library is a critical knowledge asset. Its security model must reduce the
impact of a compromise and prevent implicit lateral access between unrelated knowledge
compartments.

Cybersecurity is therefore both an academic knowledge area and an engineering control
layer used to protect the library and the systems built from it.

## Compartment model

The library currently has explicit security domains:

- Core Computing
- AI and Data
- Systems and Networking
- Software Engineering
- Interactive Computing
- Cybersecurity
- Society, Ethics and Profession

Every canonical knowledge area is assigned to exactly one domain in the application
policy.

## Controlled access path

Knowledge consumers must not receive arbitrary database credentials.

The intended production path is:

Identity -> Access Policy -> Domain Guard -> Query Guard -> Data -> Audit

Cross-domain retrieval must pass through an explicit policy decision. A compromise of
one compartment must not imply access to unrelated compartments.

## Least privilege

Students and learning agents receive only explicitly granted read/search permissions.
They do not receive arbitrary writes, exports, or library administration.

The cybersecurity domain is a separate high-sensitivity compartment. Security
administration is intentionally distinct from ordinary knowledge-agent access.

## Defense layers

The production implementation should enforce the same domain identifiers and policy at:

API gateway -> authorization service -> domain service -> database role/schema -> data

For sensitive or high-risk domains, stronger physical isolation can be introduced with
separate schemas, databases, services, network segments, or credentials according to the
threat model.

## Incident containment

The production security layer should support:

1. deny by default;
2. explicit authorization per domain and operation;
3. separate service identities;
4. encrypted service-to-service communication;
5. audit logging;
6. anomaly detection;
7. domain quarantine;
8. credential revocation;
9. recovery from known-good snapshots;
10. post-incident review.

The Flutter model establishes the domain and policy boundary; it is not a substitute for
backend, network, database, and infrastructure security.

## Relationship to TOFAN Abqari

The future Abqari must retrieve knowledge through a guarded library interface:

Abqari request -> security policy -> approved domain(s) -> knowledge retrieval -> evidence

It must never receive unrestricted database access.

Experimental observations produced by future simulation must remain distinguishable from
canonical academic knowledge and must not silently overwrite the academic source.

## Engineering principle

The library is built as a knowledge system, not merely a collection of screens. Academic
content, retrieval metadata, security controls, assessment evidence, and future
simulation experience must have explicit boundaries so that each layer can be audited,
tested, and evolved independently.

## Quality gate

Every new knowledge area requires a security-domain assignment. Every new access
capability requires an explicit policy rule. Security tests are part of the library
quality gate and must remain green as the library expands.
