package eventManagement.util;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class PasswordUtil {

    private static final int ITERATIONS = 600000;
    private static final int KEY_LENGTH = 256;
    private static final int SALT_LENGTH = 16;

    public static String hashPassword(String password) {
        byte[] salt = new byte[SALT_LENGTH];
        new SecureRandom().nextBytes(salt);

        PBEKeySpec spec = new PBEKeySpec(
                password.toCharArray(),
                salt,
                ITERATIONS,
                KEY_LENGTH
        );

        try {
            SecretKeyFactory factory =
                    SecretKeyFactory.getInstance(
                            "PBKDF2WithHmacSHA256"
                    );

            byte[] hash = factory.generateSecret(spec)
                                 .getEncoded();

            return "pbkdf2$" + ITERATIONS + "$"
                    + Base64.getEncoder().encodeToString(salt)
                    + "$"
                    + Base64.getEncoder().encodeToString(hash);

        } catch (NoSuchAlgorithmException
                 | InvalidKeySpecException e) {
            throw new IllegalStateException(
                    "Password hashing failed", e);
        } finally {
            spec.clearPassword();
        }
    }
    
    public static boolean verifyPassword(
            String password, String storedHash) {

        if (password == null || storedHash == null) {
            return false;
        }

        try {
            String[] parts = storedHash.split("\\$", -1);

            if (parts.length != 4
                    || !"pbkdf2".equals(parts[0])) {
                return false;
            }

            int iterations = Integer.parseInt(parts[1]);

            // Reject unexpected or unsafe iteration counts
            if (iterations < 1 || iterations > 1000000) {
                return false;
            }

            byte[] salt =
                    java.util.Base64.getDecoder()
                            .decode(parts[2]);

            byte[] expectedHash =
                    java.util.Base64.getDecoder()
                            .decode(parts[3]);

            if (salt.length != 16 || expectedHash.length != 32) {
                return false;
            }

            javax.crypto.spec.PBEKeySpec spec =
                    new javax.crypto.spec.PBEKeySpec(
                            password.toCharArray(),
                            salt,
                            iterations,
                            256
                    );

            try {
                javax.crypto.SecretKeyFactory factory =
                        javax.crypto.SecretKeyFactory.getInstance(
                                "PBKDF2WithHmacSHA256"
                        );

                byte[] actualHash =
                        factory.generateSecret(spec).getEncoded();

                return MessageDigest.isEqual(
                        expectedHash, actualHash);

            } finally {
                spec.clearPassword();
            }

        } catch (Exception e) {
            return false;
        }
    }
}

