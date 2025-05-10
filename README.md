# Noir ZK Proof for Combined Eligibility Criteria (Simplified)

This project demonstrates a simplified Zero-Knowledge proof using Noir that allows a user to prove they simultaneously satisfy multiple, independent eligibility criteria without revealing the specific private data that meets each criterion, nor their direct identity. It generates an overall eligibility commitment and a session nullifier.

## Core Concept (Simplified "KYC-Lite" or Multi-Factor Access)

A user wants to prove they meet, for example, two criteria:
1.  **Criterion A (e.g., Membership)**: They possess a `secret_for_criterion_a` that, when combined with a `public_target_criterion_a_id` (like a group ID), matches a `known_validity_commitment_for_a`. This acts as a simplified proof of belonging or knowledge.
2.  **Criterion B (e.g., Attribute Check)**: Their private `private_attribute_for_b` (like age) satisfies a condition related to a `public_attribute_threshold_b` (e.g., age >= 21).

The ZK circuit allows the user (identified by a `user_main_secret` for nullifier/commitment purposes) to prove:
*   They satisfy Criterion A.
*   They satisfy Criterion B.
*   They correctly formed a `claimed_combined_eligibility_commitment` signifying both criteria are met for the current `session_id`.
*   They correctly formed a `claimed_session_nullifier`.

A verifier can check the proof to confirm combined eligibility for a specific `session_id` (and check the nullifier for uniqueness) without learning the user's secrets or specific attribute values.

## Project Structure

(Standard Noir project structure)

## Circuit Logic (`src/main.nr`)

The Noir circuit takes:
*   **Private Inputs**: `user_main_secret`, `secret_for_criterion_a`, `private_attribute_for_b`, `eligibility_commitment_blinding_factor`.
*   **Public Inputs**: Parameters for Criterion A (`public_target_criterion_a_id`, `known_validity_commitment_for_a`), parameters for Criterion B (`public_attribute_threshold_b`, `condition_type_b`), `session_id`, `overall_eligibility_tag_field`, `claimed_combined_eligibility_commitment`, `claimed_session_nullifier`.

It constrains:
1.  `pedersen_hash([secret_for_criterion_a, public_target_criterion_a_id])` equals `known_validity_commitment_for_a`.
2.  `private_attribute_for_b` satisfies the condition based on `public_attribute_threshold_b` and `condition_type_b`.
3.  `claimed_combined_eligibility_commitment` is correctly formed using `user_main_secret` and public context.
4.  `claimed_session_nullifier` is correctly formed using `user_main_secret` and `session_id`.

## Prerequisites

*   **Nargo**: Noir's package manager. Install from [official documentation](https://noir-lang.org/docs/getting_started/installation/).

## How to Run

1.  **Setup Project**: Create files and structure.
2.  **Crucial: Update Hash Placeholders**: All commitment and nullifier values in `.toml` files are **placeholders**. Recompute them using private/public inputs and `pedersen_hash`. Ensure tag fields are consistent.
3.  **Compile**: `nargo compile`
4.  **Generate Proof**: `nargo prove`
5.  **Verify Proof**: `nargo verify`

## Simplifications & Extensions

*   **Criterion A Verification**: Uses a simplified secret knowledge check. Real membership might involve Merkle proofs against a group root.
*   **Attribute Complexity**: Criterion B handles a simple threshold. Could be extended for more complex attribute types or logic.
*   **Number of Criteria**: Hardcoded for two criteria. Generalizing to 'M-out-of-N' criteria being met would be more complex.

This project serves as a basic example of composing ZK proofs for multiple conditions, a step towards more sophisticated anonymous attestations and verifiable credentials.