// src/main.nr
// ZK Proof for Combined Eligibility Criteria (Simplified "KYC-Lite")

use dep::std::hash::pedersen_hash;

// This circuit allows a user to prove they satisfy two independent criteria:
// 1. Criterion A: Knowledge of a secret (`secret_for_criterion_a`) that, when hashed
//    with a public target for criterion A, matches a known validity commitment for A.
//    (e.g., proving membership in a group defined by `public_target_criterion_a_id`).
// 2. Criterion B: A private attribute value (`private_attribute_for_b`) meets a public threshold.
//    (e.g., age >= 18).
// The proof generates an overall eligibility commitment and a session nullifier.

// A constant field for tagging commitments, e.g., pedersen_hash(["COMBINED_ELIGIBILITY_MET_TAG"])
// Passed as public input for flexibility: `overall_eligibility_tag_field`

fn main(
    // === Private Inputs (Known to the User/Prover) ===
    user_main_secret: Field,            // Main secret for user, used for nullifier and final commitment.
    
    secret_for_criterion_a: Field,      // Secret that proves satisfaction of criterion A.
    
    private_attribute_for_b: Field,     // Private attribute value for criterion B (e.g., user's age).

    // Blinding factor for the overall eligibility commitment.
    eligibility_commitment_blinding_factor: Field, 

    // === Public Inputs ===
    // For Criterion A (e.g., group membership check)
    // `public_target_criterion_a_id` could be hash of a group name, community ID, etc.
    public_target_criterion_a_id: pub Field,
    // `known_validity_commitment_for_a` is a public value meaning "if you can make this hash, you satisfy Criterion A".
    // e.g., hash(THE_GROUP_SECRET_KNOWN_BY_MEMBERS, public_target_criterion_a_id)
    known_validity_commitment_for_a: pub Field,

    // For Criterion B (e.g., age check)
    public_attribute_threshold_b: pub Field, // e.g., 18 for age.
    // condition_type_b: 0 for "==", 1 for ">=", 2 for "<=" (simplified)
    condition_type_b: pub Field,

    session_id: pub Field,                  // Unique ID for this proof session.
    overall_eligibility_tag_field: pub Field, // Public constant tag.
    
    // Prover claims these.
    claimed_combined_eligibility_commitment: pub Field,
    claimed_session_nullifier: pub Field
) {
    // --- 1. Verify Criterion A (e.g., Group Membership via Secret Knowledge) ---
    // Prover shows they know `secret_for_criterion_a` that validates against the public target for A.
    let computed_validity_for_a = pedersen_hash([secret_for_criterion_a, public_target_criterion_a_id]);
    constrain computed_validity_for_a == known_validity_commitment_for_a;

    // --- 2. Verify Criterion B (e.g., Attribute Threshold Check) ---
    let mut criterion_b_met = false;
    if condition_type_b == 1 { // Greater than or equal to
        if private_attribute_for_b >= public_attribute_threshold_b {
            criterion_b_met = true;
        }
    } // Add else if for other condition_types (==, <=) if needed
    else if condition_type_b == 0 { // Equals
        if private_attribute_for_b == public_attribute_threshold_b {
            criterion_b_met = true;
        }
    }
    // Constrain that a valid condition_type_b was used (e.g. 0 or 1)
    constrain (condition_type_b == 0) || (condition_type_b == 1);
    constrain criterion_b_met == true;


    // --- 3. Compute and Verify Combined Eligibility Commitment ---
    // If both criteria are met (implicitly by constraints passing), form the commitment.
    // This commitment links the user's main secret, the context of both criteria (represented by their public params),
    // the session, and a validity tag.
    let computed_combined_eligibility_commitment = pedersen_hash([
        user_main_secret,
        public_target_criterion_a_id, // Context of criterion A
        public_attribute_threshold_b, // Context of criterion B
        condition_type_b,             // Context of criterion B condition
        session_id,
        overall_eligibility_tag_field,
        eligibility_commitment_blinding_factor
    ]);
    constrain computed_combined_eligibility_commitment == claimed_combined_eligibility_commitment;

    // --- 4. Compute and Verify Session Nullifier ---
    // Prevents re-using this combined proof for the same user in the same session.
    let computed_session_nullifier = pedersen_hash([user_main_secret, session_id]);
    constrain computed_session_nullifier == claimed_session_nullifier;
    
    // println("Combined Criteria Eligibility Proof Validated.");
}