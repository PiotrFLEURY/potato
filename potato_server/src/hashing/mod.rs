use sha2::{Digest, Sha256};

pub fn is_classic_room_code(code: &str) -> bool {
    code.len() == 8 && code.chars().all(|c| c.is_ascii_alphanumeric())
}

pub fn is_hashed_room_id(id: &str) -> bool {
    id.len() == 64 && id.chars().all(|c| c.is_ascii_hexdigit())
}

pub fn hash_room_code(code: &str) -> String {
    if !is_classic_room_code(code) {
        return code.to_string();
    }
    let mut hasher = Sha256::new();
    hasher.update(code.as_bytes());
    let hash = hasher.finalize();

    // hex to String for storage in the database
    hash.iter().map(|byte| format!("{:02x}", byte)).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_classic_room_code() {
        let valid_code = "ABCD1234";
        let invalid_code = "ABCD-1234";
        assert!(is_classic_room_code(valid_code));
        assert!(!is_classic_room_code(invalid_code));
    }

    #[test]
    fn test_is_hashed_room_id() {
        let room_id = "ABCD1234";
        let hashed_id = hash_room_code(room_id);
        assert!(is_hashed_room_id(&hashed_id));
        assert!(!is_hashed_room_id(room_id));
    }

    #[test]
    fn test_hash_room_code() {
        let code = "ABCDEFGH";
        let expected_hash = "9ac2197d9258257b1ae8463e4214e4cd0a578bc1517f2415928b91be4283fc48";
        assert_eq!(hash_room_code(code), expected_hash);
    }
}
